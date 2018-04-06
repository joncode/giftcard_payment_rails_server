class Merchant < ActiveRecord::Base
    HEX_ID_PREFIX = 'mt_'
    include HexIdMethods
    include CompanyDuckType
    include ShortenPhotoUrlHelper
    include Formatter
    include Utility
    include MerchantSerializers
    include RedeemHelper
    include MoneyHelper

    # default_scope -> { where(active: true).where(paused: false).order("name ASC") }  # indexed w/ city

    scope :live_scope, -> { where(active: true, paused: false, live: true) }
    scope :coming_scope, -> { where(active: true, paused: false, live: false) }

#   -------------

    before_validation :extract_phone_digits
    before_validation :strip_whitespace_and_fix_case
    before_validation   :create_token

#   -------------

    validates :rate, numericality: { less_than: 100, greater_than_or_equal_to: 0 }, allow_blank: true
    validates_presence_of :name, :address, :state, :zip
    validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: true
    validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: true
    validates :signup_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: true
    validates_length_of :zinger, :maximum => 90
    validates_length_of :description, :maximum => 500
    validates_length_of :ein, :within => 8..12, allow_blank: :true

#   -------------

    before_save :add_region_name
    before_save :set_live_at

    after_create  :create_menu
    after_create  :create_quick_gifts

    after_commit :clear_www_cache, on: [:create, :update, :destroy]

#   -------------

    has_one :affiliate, through: :affiliation
    has_one :affiliation, as: :target
    has_one :provider
    has_one :merchant_signup
    has_one :legal, as: :company

    has_many :books
    has_many :campaign_items
    has_many :gifts
    has_many :licenses, as: :partner
    has_many :payments,     as: :partner
    has_many :print_queues
    has_many :protos
    has_many :registers,    as: :partner
    has_many :sales

    has_many :access_grants, class_name: UserAccess
    has_many :access_codes,  class_name: UserAccessCode, foreign_key: :owner_id, foreign_type: "Merchant"  # a rather verbose `polymorphic: true`

    belongs_to :brand
    belongs_to :client
    belongs_to :region

#   -------------

    enum payment_event: [ :creation, :redemption ]
    enum payment_plan: [ :no_plan, :choice, :prime ]

    def as_json
        super(except: [:id, :region_id, :pos_merchant_id, :client_id, :building_id, :brand_id, :rate, :account_admin_id, :ein,
                :token, :tender_type_id, :facebook, :twitter, :bank_id, :promo_menu_id, :setup, :tou, :ftmeta, :affiliate_id,
                :prime_date, :prime_amount, :payment_event, :payment_plan, :tools, :created_at, :updated_at, :signup_email, :signup_name, :contract_date,
                :menu_is_live, :pos_direct, :pos_sys, :active])
    end

    def biz_user
        BizUser.find(self.id)
    end

    def zone
        TIME_ZONES[self.tz]
    end

    def self.index
        live_scope
    end

    delegate :verified?, to: :legal, allow_nil: true

    def destination_hsh float_or_string='0'
        return {} if Rails.env.production? # not ready for production yet
        return {} if country == 'US'
        if verified?
            puts "Stripe Connect Account for Merchant #{self.id}"
            { destination: { amount: currency_to_cents(float_or_string.to_s), account: legal.stripe_account_id }}
        else
            puts "NO Stripe Connect Account for Merchant #{self.id}"
            {}
        end
    end

#   -------------

    def clover_auth_token
        self.tender_type_id
    end

    def clover_auth_token= auth_token
        if auth_token.present? && clover_auth_token != auth_token
            puts "Merchant::clover_auth_token setting auth_token #{self.id}"
            update(tender_type_id: auth_token)
        end
    end


#   -------------            MUILTI REDEMPTION METHODS

    def multi_redemption_client
        self.client
    end

    def multi_redeemable?
        self.client_id.present?
    end

    def multi_redemption_merchants
        c = self.multi_redemption_client
        if c.nil?
            [self]
        else
            arg_scope = proc { Merchant.where(active: true, paused: false) }
            c.contents(:merchants, &arg_scope)
        end
    end

    def multi_redemption_merchant_ids
        multi_redemption_merchants.map(&:id)
    end

    def get_redemptions_for_hex_id_or_token value
        value = value.to_s
        if value.length == 4
            Redemption.get_multi_with_token(value, multi_redemption_merchant_ids)
        else
            hex_id = value.downcase.gsub('rd-', 'rd_').gsub('-','')
            Redemption.get_multi_with_hex_id(hex_id, multi_redemption_merchant_ids)
        end
    end

#   -------------

    def pending_redeems
        gifts = Gift.where(merchant_id: self.id, status: ['notified', 'redeemed']).where('new_token_at > ?', reset_time)
        notified_gifts = gifts.where(status: 'notified').order("created_at DESC")
        redeemed_gifts = gifts.where(status: 'redeemed').order("redeemed_at DESC")
        notified_gifts + redeemed_gifts
    end

    def self.count_for(partner)
        if partner.kind_of?(Affiliate)
            live_scope.where(affiliate_id: partner.id).count
        elsif partner.kind_of?(Merchant)
            1
        end
    end

#   -------------

    def menu_string
        begin
            if menu = Menu.find(self.menu_id)
                JSON.parse(menu.json)
            else
                []
            end
        rescue
            []
        end
    end

    def active_live?
        self.active && mode == "live" && !self.zip.match('11111')
    end

    def mode
        if self.paused
            return "paused"
        else
            if self.live
                return "live"
            else
                return "coming_soon"
            end
        end
    end

    def mode= mode_str
        case mode_str.downcase
        when "live"
            self.paused = false
            self.live   = true
        when "coming_soon"
            self.paused = false
            self.live   = false
        when "paused"
            self.paused = true
        else
            # cron job to fix the broken mode_str
            puts "#{self.name} #{self.id} was sent mode_str #{mode_str} - update mode broken"
        end
    end

    def live_int
        self.live ? "1" : "0"
    end

    def deactivate
        self.paused = true
        self.live   = false
        self.active = false
        if self.save
            true
        else
            false
        end
    end

#   -------------


    def shift_start
        x = now
        x -= 1.day if x.hour < 8
        x = x.beginning_of_day.change(hour: 8)
        x
    end

    def now
        TimeGem.change_time_to_zone(DateTime.now.utc, timezone)
    end

    def current_time time_stamp=nil
        time_stamp ||= now
        TimeGem.timestamp_to_s(TimeGem.change_time_to_zone(time_stamp, timezone))
    end

    def city
        self.city_name
    end

    def city= name
        self.city_name = name
    end

    def country
        { 'USD' => 'US' , "CAD" => 'CA', "GBP" => 'GB'}[self.ccy]
    end

    def location_fee(convert_these_cents=nil)
        r_cents = self.rate / 100.0
        if convert_these_cents
            (convert_these_cents * r_cents).to_i
        else
            r_cents
        end
    end

    def override_fee(convert_these_cents=nil)
        return 0 if self.affiliate_id.nil?
        if self.rate == 90
            o_rate = 7
        elsif self.rate == 85
            OpsTwilio.text_devs msg: "Location fee 85% #{self.id}"
            o_rate = 4
        else
            o_rate = 4
        end
        if convert_these_cents
            (convert_these_cents * o_rate / 100)
        else
            o_rate / 100.0
        end
    end


#   -------------

    def widget_instruction_url
        c = clients.where(active: true).where("url_name ilike '74-%%'").first
        instructons = CLEAR_CACHE + "/merchants/widget"
        if c
            instructons + "?id=#{c.url_name}"
        end
        instructons
    end

    def short_image_url
        shorten_photo_url(image)
    end

    def get_logo
        if photo_l.present?
            photo_l
        else
            "https://res.cloudinary.com/drinkboard/image/upload/v1408401050/blank_logo_njwzxk.png"
        end
    end

    def get_logo_web
        self.photo_l
    end

    def get_photo default: true
        if photo
            unshorten_photo_url(photo)
        elsif image
            image
        else
            MERCHANT_DEFAULT_IMG
        end
    end

#   -------------

    ##########  AFFILIATION DUCKTYPE
        def name_address_hsh
            h            = {}
            h["name"]    = self.name
            h["address"] = self.address
            h
        end

        def create_affiliation(affiliate)
            self.affiliate_id = affiliate.id
        end
    ###########


    def itsonme_url
        "#{CLEAR_CACHE}/share/merchants/#{self.id}"
    end

    def api_url
        "#{APIURL}/merchants/#{self.id}"
    end

    def string_token
        "#{MERCHANT_ID}-#{self.id}-#{make_slug(self.name)}"
    end

private

    def add_region_name
        if self.region_id.present? && (self.region_name.nil? || self.region_id_changed?)
            region = Region.unscoped.where(id: self.region_id).first
            self.region_name = region.name if region.present?
        else
            self.region_name = nil if self.region_id.nil?
        end
    end

    def strip_whitespace_and_fix_case
        self.name  = self.name.strip if self.name.present?
        self.address = self.address.strip if self.address.present?
        self.zip   = self.zip.strip if self.zip.present?
        self.ein   = self.ein.strip if self.ein.present?
        self.email = self.email.downcase.strip if self.email.present?
        # self.city_name  = self.city_name.titleize.strip if self.city_name.present?
        self.signup_email = self.signup_email.downcase.strip if self.signup_email.present?
        self.signup_name = self.signup_name.strip if self.signup_name.present?
    end

    def clear_www_cache
        if !Rails.env.development? || !Rails.env.test?
            RedisWrap.clear_merchants_caches(self.region_id) if self.region_id
            RedisWrap.clear_merchants_caches(self.city_id) if self.city_id
            WwwHttpService.clear_merchant_cache
        end
    end

#   -------------

    def create_quick_gifts
        mis = self.menu.menu_items if self.menu
        mis.each do |menu_item|
            proto = Proto.new_with_menu_item(item: menu_item, company: self)
            proto.save if proto.kind_of?(Proto)
        end
    end

    def create_menu
        menu = MenuFull.create(owner_id: self.id, owner_type: self.class.to_s)
        if menu.persisted?
            menu.compile_menu_to_app
            update(menu_id: menu.id)
            menu
        else
            menu
        end
    end

    def set_live_at
        if self.live_at.nil? && self.mode == 'live'
            self.live_at = TimeGem.change_time_to_zone(DateTime.now.utc, self.zone).to_date
        end
    end

    def create_token
        self.token = generate_token if self.token.nil?
    end

end



# == Schema Information
#
# Table name: merchants
#
#  id               :integer         not null, primary key
#  name             :string(255)
#  token            :string(255)
#  zinger           :string(255)
#  description      :text
#  active           :boolean         default(TRUE)
#  address          :string(255)
#  address_2        :string(255)
#  city             :string(50)
#  state            :string(2)
#  zip              :string(16)
#  phone            :string(20)
#  email            :string(255)
#  website          :string(255)
#  facebook         :string(255)
#  twitter          :string(255)
#  photo            :string(255)
#  photo_l          :string(255)
#  rate             :decimal(, )     default(85.0)
#  sales_tax        :decimal(8, 3)
#  setup            :string(255)     default("000010")
#  image            :string(255)
#  pos              :boolean         default(FALSE)
#  tou              :boolean         default(FALSE)
#  tz               :integer         default(0)
#  live             :boolean         default(FALSE)
#  paused           :boolean         default(TRUE)
#  latitude         :float
#  longitude        :float
#  ein              :string(255)
#  region_id        :integer
#  pos_merchant_id  :string(255)
#  account_admin_id :integer
#  ftmeta           :tsvector
#  r_sys            :integer         default(2)
#  created_at       :datetime
#  updated_at       :datetime
#  affiliate_id     :integer
#  payment_event    :integer         default(0)
#  tender_type_id   :string(255)
#  pos_sys          :string(255)
#  prime_amount     :integer
#  prime_date       :date
#  contract_date    :date
#  signup_email     :string(255)
#  signup_name      :string(255)
#

