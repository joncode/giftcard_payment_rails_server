class Register < ActiveRecord::Base
	enum origin:  [ :iom, :loc, :aff_user, :aff_loc, :aff_link ]
	enum type_of: [ :debt, :credit ]
	attr_accessor :affiliation

	belongs_to :partner,  polymorphic: true, autosave: true
	belongs_to :gift
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
			self.partner.user_gift_created(self.amount, gift)
		elsif self.aff_loc?
			self.partner.merchant_gift_created(self.amount, gift)
		elsif  self.aff_link?
			self.partner.link_gift_created(self.amount, gift)
		end
	end
end

# == Schema Information
#
# Table name: registers
#
#  id           :integer         not null, primary key
#  gift_id      :integer
#  amount       :integer
#  partner_id   :integer
#  partner_type :string(255)
#  origin       :integer         default(0)
#  type_of      :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

