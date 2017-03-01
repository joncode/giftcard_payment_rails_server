class Merchant < ActiveRecord::Base
    include CompanyDuckType
    include ShortenPhotoUrlHelper
    include Formatter
    include MerchantSerializers
    include RedeemHelper

    # default_scope -> { where(active: true).where(paused: false).order("name ASC") }  # indexed w/ city

    scope :live_scope, -> { where(active: true, paused: false, live: true) }
    scope :coming_scope, -> { where(active: true, paused: false, live: false) }

#   -------------

    before_validation :extract_phone_digits
    before_validation :strip_whitespace_and_fix_case

#   -------------

    validates_presence_of :name, :address, :state, :zip, :city_id
    validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: :true
    validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates :signup_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates_length_of :zinger, :maximum => 90
    validates_length_of :description, :maximum => 500
    validates_length_of :ein, :within => 8..12, allow_blank: :true

#   -------------

    before_save     :add_region_name

    after_commit :clear_www_cache, on: [:create, :update, :destroy]

#   -------------

    has_one :affiliate, through: :affiliation
    has_one :affiliation, as: :target
    has_one :provider
    has_one :merchant_signup

    has_many :campaign_items
    has_many :gifts
    has_many :licenses, as: :partner
    has_many :payments,     as: :partner
    has_many :protos
    has_many :providers_socials
    has_many :registers,    as: :partner
    has_many :sales
    has_many :socials, through: :providers_socials

    belongs_to :brand
    belongs_to :client
    belongs_to :region

#   -------------

    enum payment_event: [ :creation, :redemption ]
    enum payment_plan: [ :no_plan, :choice, :prime ]

    def biz_user
        BizUser.find(self.id)
    end

    def zone
        TIME_ZONES[self.tz]
    end

    def self.index
        live_scope
    end

#   -------------

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
        self.active && self.mode == "live"
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

    def city
        self.city_name
    end

    def city= name
        self.city_name = name
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

