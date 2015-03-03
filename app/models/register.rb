class Register < ActiveRecord::Base
	enum origin:  [ :iom, :loc, :aff_user, :aff_loc, :aff_link ]
	enum type_of: [ :debt, :credit ]
	attr_accessor :affiliation

	belongs_to :partner,  polymorphic: true, autosave: true
	belongs_to :gift
	belongs_to :payment
	before_validation :update_partner

	validates_presence_of :partner_id, :partner_type

	after_save :save_affiliation

	def payment_type
		if self.loc? || self.aff_loc?
			:merchant
		elsif self.aff_user?
			:user
		elsif self.aff_link?
			:link
		else
			:internal
		end
	end

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

