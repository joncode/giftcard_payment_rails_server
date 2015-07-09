class Merchant < ActiveRecord::Base
    include ShortenPhotoUrlHelper
    include Formatter

#   -------------

    before_validation :extract_phone_digits
    before_validation :strip_whitespace_and_fix_case

#   -------------

    validates_presence_of :name, :address, :city_name, :state, :zip, :city_id
    validates :phone , format: { with: VALID_PHONE_REGEX }, allow_blank: :true
    validates :email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates :signup_email , format: { with: VALID_EMAIL_REGEX }, allow_blank: :true
    validates_length_of :zinger, :maximum => 90
    validates_length_of :description, :maximum => 500
    validates_length_of :ein, :within => 8..12, allow_blank: :true

#   -------------

    before_save :add_region_name

#   -------------

    has_one :provider
    has_one :affiliation, as: :target
    has_one :affiliate, through: :affiliation
    has_many :payments,     as: :partner
    has_many :registers,    as: :partner
    has_many :invites,  as: :company
    has_many :mt_users, through: :invites

    belongs_to :region
    belongs_to :bank

#   -------------

    enum payment_event: [ :creation, :redemption ]
    enum payment_plan: [ :no_plan, :choice, :prime ]

    def biz_user
        BizUser.find(self.id)
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

#   -------------

    def city
        self.city_name
    end

    def city= name
        self.city_name = name
    end

#   -------------

    def get_logo
        if photo_l.present?
            photo_l
        else
            "http://res.cloudinary.com/drinkboard/image/upload/v1408401050/blank_logo_njwzxk.png"
        end
    end

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

    def add_region_name
        if self.region_id.present? && (self.region_name.nil? || self.region_id_changed?)
            region = Region.unscoped.where(id: self.region_id).first
            self.region_name = region.name if region.present?
        else
            self.region_name = nil if self.region_id.nil?
        end
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

    def get_photo default: true
        if default && image.blank?
            return MERCHANT_DEFAULT_IMG
        end
        image
    end

private

    def strip_whitespace_and_fix_case
        self.name  = self.name.strip if self.name.present?
        self.address = self.address.strip if self.address.present?
        self.zip   = self.zip.strip if self.zip.present?
        self.ein   = self.ein.strip if self.ein.present?
        self.email = self.email.downcase.strip if self.email.present?
        self.city_name  = self.city_name.titleize.strip if self.city_name.present?
        self.signup_email = self.signup_email.downcase.strip if self.signup_email.present?
        self.signup_name = self.signup_name.strip if self.signup_name.present?
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

