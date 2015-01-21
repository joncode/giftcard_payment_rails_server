class Affiliation < ActiveRecord::Base

	enum status: [ :on, :pause, :done, :cancel ]

	belongs_to :affiliate, autosave: true
	belongs_to :target, polymorphic: true, autosave: true

	before_validation :set_up_data, on: :create

	def self.get_merchant_affiliation_for_gift(gift)
		return nil 	 unless provider = gift.provider
		return nil 	 unless merchant = provider.merchant
		return false unless affiliation = merchant.affiliation
		return false unless affiliation.on?
		return false if affiliation.payout > 9999
		affiliation
	end

	def self.get_user_affiliation_for_gift(gift)
		return nil 	 unless giver = gift.giver
		return false unless affiliation = giver.affiliation
		return false unless affiliation.on?
		return false if affiliation.payout > 9999
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

