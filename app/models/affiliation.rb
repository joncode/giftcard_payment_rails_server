class Affiliation < ActiveRecord::Base

	before_validation :set_up_data, on: :create

#   -------------

	belongs_to :affiliate, autosave: true
		#  Merchant || User == Target
	belongs_to :target, polymorphic: true, autosave: true

#   -------------

	enum status: [ :on, :pause, :done, :cancel ]

#   -------------

	def self.get_merchant_affiliation_for_gift(gift)
		return nil 	 unless provider = gift.provider
		return nil 	 unless merchant = provider.merchant
		return false unless affiliation = merchant.affiliation
		return false unless affiliation.on?
		return false if affiliation.payout > 999999   # $10,000 in cents
		affiliation
	end

	def self.get_user_affiliation_for_gift(gift)
		return nil 	 unless giver = gift.giver
		return false unless affiliation = giver.affiliation
		return false unless affiliation.on?
		return false if affiliation.payout > 9999 	# $1,000 in cents
		affiliation
	end

private

	def set_up_data
		self.target.create_affiliation(self.affiliate)
		name_addr_hsh = self.target.name_address_hsh
		self.name     = name_addr_hsh["name"]
		self.address  = name_addr_hsh["address"]
		self.affiliate.create_affiliation(self.target_type)
	end
end

# == Schema Information
#
# Table name: affiliations
#
#  id           :integer         not null, primary key
#  affiliate_id :integer
#  target_id    :integer
#  target_type  :string(255)
#  name         :string(255)
#  address      :string(255)
#  payout       :integer         default(0)
#  status       :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

