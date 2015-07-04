class Merchant < ActiveRecord::Base

    before_save     :add_region_name

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

