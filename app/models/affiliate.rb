class Affiliate < ActiveRecord::Base
    include CompanyDuckType


#   -------------

    auto_strip_attributes :first_name, :company, :last_name, :email, :zip, :city, :address

#   -------------

	has_many :affiliate_gifts
	has_many :affiliations
	has_many :gifts, through: :affiliate_gifts
	has_many :landing_pages
    has_many :licenses, as: :partner
	has_many :merchants, through: :affiliations, source: :target, source_type: 'Merchant'
	has_many :payments,     as: :partner
	has_many :registers,    as: :partner
	has_many :users, 	 through: :affiliations, source: :target, source_type: 'User'

#   -------------

    def self.location_fee merchant_location_fee
        merchant_location_fee == 90 ? 7 : 4
    end

    def multi_redemption_client
        self.clients.redemption.first
    end

    def multi_redeemable?
        multi_redemption_client.length > 0
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

#   -------------

	def create_affiliation(target_type)
		if target_type == "User"
			self.total_users += 1
		elsif target_type == "Merchant"
			self.total_merchants += 1
		else
			# unknown target type
		end
	end

	def link_gift_created amount, gift
		self.payout_links	+= amount
		self.purchase_links	+= 1
		self.value_links	+= gift_value_or_calculate_value_from_amount(gift, amount)
	end

	def user_gift_created amount, gift
		self.payout_users	+= amount
		self.purchase_users	+= 1
		self.value_users	+= gift_value_or_calculate_value_from_amount(gift, amount)
	end

	def merchant_gift_created amount, gift
		self.payout_merchants	+= amount
		self.purchase_merchants	+= 1
		self.value_merchants	+= gift_value_or_calculate_value_from_amount(gift, amount)
	end

	def account_admin_email
		self.email
	end

	def status
		"live"
	end

	def name
		if self.last_name.blank?
			self.first_name
		else
			"#{self.first_name} #{self.last_name}"
		end
	end

	def list_serialize
		hsh = web_serialize
		hsh['type'] = 'super_merchant'
		hsh
	end

	def web_serialize
		prov_hash  = {}
		prov_hash["loc_id"]     = self.id
		prov_hash["name"]     = self.company
		prov_hash["ccy"]     = self.ccy
		prov_hash["loc_street"] = self.address
		prov_hash["loc_city"]   = self.city
		prov_hash["loc_state"]  = self.state
		prov_hash["loc_zip"]    = self.zip
		prov_hash["live"]      = true
		prov_hash["status"]    = status
		prov_hash['multi_loc'] = 'yes'
		prov_hash
	end

private

	def gift_value_or_calculate_value_from_amount(gift=nil, amount)
		if gift.nil?
			amount * 67
		else
			gift.value_cents
		end
	end

end
# == Schema Information
#
# Table name: affiliates
#
#  id                 :integer         not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  email              :string(255)
#  phone              :string(255)
#  address            :string(255)
#  state              :string(255)
#  city               :string(255)
#  zip                :string(255)
#  url_name           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  total_merchants    :integer         default(0)
#  payout_merchants   :integer         default(0)
#  total_users        :integer         default(0)
#  payout_users       :integer         default(0)
#  payout_links       :integer         default(0)
#  value_links        :integer         default(0)
#  value_users        :integer         default(0)
#  value_merchants    :integer         default(0)
#  purchase_links     :integer         default(0)
#  purchase_users     :integer         default(0)
#  purchase_merchants :integer         default(0)
#  company            :string(255)
#  website_url        :string(255)
#

