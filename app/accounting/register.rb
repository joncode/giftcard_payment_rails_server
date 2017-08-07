class Register < ActiveRecord::Base


	before_validation :update_partner, on: :create

	validates_presence_of :partner_id, :partner_type

#   -------------

	after_create :save_affiliation

#   -------------

		#  Merchant || Affiliate == Partner
	belongs_to :partner,  polymorphic: true, autosave: true
	belongs_to :gift

	def gift
		Gift.unscoped.where(id: self.gift_id).first
	end

	belongs_to :payment
	belongs_to :license

#   -------------

	def self.cats
		['ACCRUAL', 'REFUND', 'ADJUST']
	end

	def fee_type
		return 'N/A' if origin.nil?
		FEE_TYPES[origin.to_sym]
	end

	FEE_TYPES = { iom: "ItsOnMe", loc: "Location Fee", aff_user: "User Override", aff_loc: "Commission Fee", aff_link: "Promo Link",
			subscription: 'Subscription', promo: 'Promotion' }
	enum origin:  [ :iom, :loc, :aff_user, :aff_loc, :aff_link, :subscription, :promo ]
	enum type_of: [ :debt, :credit ]

	attr_accessor :affiliation

#   -------------

	def self.get_unpaid_in_range start_date: , end_date:
		where(created_at: start_date .. end_date, payment_id: nil)
	end

	def self.get_unpaid_invoices
		where(partner_id: nil, gift_id: nil).where.not(license_id: nil)
	end

	def self.init_with_charge_object charge_object
		#<Register id: 8659, gift_id: 362204, amount: 900, partner_id: 75, partner_type: "Merchant",
		# origin: 1, type_of: 0, created_at: "2016-09-13 18:43:05", updated_at: "2016-09-13 18:43:05", payment_id: nil, ccy: "USD">
		charge_object.symbolize_keys!
		reg = new
		reg.partner_type = charge_object[:partner_type]
		reg.partner_id = charge_object[:partner_id]
		reg.type_of = charge_object[:type] # charge / refund
		reg.origin = charge_object[:origin]
		reg.amount = charge_object[:amount]
		reg.ccy = charge_object[:ccy]
		reg.license_id = charge_object[:license_id]
		reg.note = charge_object[:name] + '|' + charge_object[:detail]
		reg.cat = cats[0]
		reg
	end

	def self.last_for_license(license)
		where(license_id: license.id).order(created_at: :desc).last
	end

#   -------------


	def self.init_debt gift_obj, partner_obj, pay_amount, origin_type
		return nil if gift_and_parents_paid_already?(gift_obj, origin_type)
		make gift_obj, pay_amount, 'debt', partner_obj, origin_type
	end

	def self.make gift_obj, pay_amount, credit_debt='debt', partner_obj=nil, origin_type='loc'
		return nil unless (pay_amount.to_i > 0)
		return nil if origin_type != 'loc' && partner_obj.nil?
		if origin_type == 'loc' && partner_obj.nil?
			partner_obj = gift_obj.merchant
		end
		reg = new
		reg.partner = partner_obj
		reg.type_of = credit_debt
		reg.origin = origin_type
		reg.amount = pay_amount
		reg.gift_id = gift_obj.id
		reg.ccy = gift_obj.converted_ccy
		if gift_obj.ccy != gift_obj.converted_ccy
			reg.note = "Converted from - #{gift_obj.ccy} #{gift_obj.value}"
		end
		reg
	end

	def self.paid_already? gift_obj, origin_type
		if origins[origin_type].nil?
			puts "500 Internal - WRONG ORIGIN TYPE Register[29] #{origin_type} - #{gift_obj.id}"
			return true
		end
		exists?(gift_id: gift_obj.id, origin: origins[origin_type])
	end

	def self.gift_and_parents_paid_already?(gift_obj, origin_type)
		if paid_already?(gift_obj, origin_type)
			return true
		else
			parent = gift_obj.parent
			if parent.kind_of?(Gift)
				gift_and_parents_paid_already?(parent, origin_type)
			else
				return false
			end
		end
	end


#   -------------


	def reverse_charge(note=nil)
		if self.payment.nil?
			reg = self.destroy
		else
			type_of_value = self.debt? ? 1 : 0
			cat_value = self.debt? ? Register.cats[1] : Register.cats[0]
			reg = Register.create(amount: self.amount,
				partner_type: self.partner_type,
				partner_id: self.partner_id,
				origin: self.origin,
				type_of: type_of_value,
				gift_id: self.gift_id,
				cat: cat_value,
				ccy: self.ccy,
				note: note)
		end
		puts "Register -reverse_charge- #{reg.inspect}"
		if reg.amount.to_i == 0
			OpsTwilio.text_devs msg: "Zero Value refund create for register ID #{reg.id}"
		end
		reg
	end

	def amount
		if credit?
			return -super
		end
		super
	end

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

	def fee_type
		FEE_TYPES[origin.to_sym]
	end


	def destroy
		return "Register is on a payment - cannot destroy" if self.payment_id.present?
		super
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
#  payment_id   :integer
#

