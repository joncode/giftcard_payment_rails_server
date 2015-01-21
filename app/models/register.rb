class Register < ActiveRecord::Base
	enum origin:  [ :iom, :loc, :aff_user, :aff_loc ]
	enum type_of: [ :debt, :credit ]
	attr_accessor :affiliation

	belongs_to :partner,  polymorphic: true, autosave: true

	before_validation :update_partner

	after_save :save_affiliation

private

	def save_affiliation
		if self.affiliation.present?
			self.affiliation.payout += self.amount
			self.affiliation.save
		end
	end

	def update_partner
		return true if self.partner.class != Affiliate
		if self.aff_user?
			self.partner.payout_users += self.amount
		elsif self.aff_loc?
			self.partner.payout_merchants += self.amount
		end
	end
end

