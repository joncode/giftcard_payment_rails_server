class Payment < ActiveRecord::Base

	before_create :set_partner_to_bank_owner

#   -------------

	has_many :registers
	has_many :gifts, through: :registers

    belongs_to :at_user
	belongs_to :partner,  polymorphic: true
	belongs_to :bank

#   -------------


	def affiliate
		self.partner
	end

#   -------------

	def self.get_current_payment_for_partner(partner_obj, start_date)
        if partner_obj.bank_id.present?
            payment = where(bank_id: partner_obj.bank_id, start_date: start_date).first_or_initialize
        else
                # bank-less payment record
            payment = where(partner: partner_obj, start_date: start_date).first_or_initialize
        end
        if payment.new_record?
            # get previous balance off previous payment
            last = self.get_last_payment_for_partner(partner_obj)
            if last && last.total < 0
                payment.previous_total = last.total
                payment.total = last.total
            end
        end
        return payment
	end

	def self.get_last_payment_for_partner(partner_obj)
        if partner_obj.bank_id.present?
            last = where(bank_id: partner_obj.bank_id).order(start_date: :desc).limit(1).first
            if last.nil?
                last = where(partner: partner_obj).order(start_date: :desc).limit(1).first
            end
        else
            last = where(partner: partner_obj).order(start_date: :desc).limit(1).first
        end
        return last
	end

	def self.get_start_date_of_payment
		now = DateTime.now.utc
			# run payments every day for QA/dev
		if Rails.env.production? || Rails.env.development?
			if now.day > 15
				return now.beginning_of_month
			else
				return (now.beginning_of_month - 1.month + 15.days)
			end
		else
			return now.beginning_of_day - 1.day
		end
	end

	def self.get_end_date_of_payment start_date=nil
		if start_date.kind_of?(String)
			start_date = Date.parse(start_date)
		end
		sd = start_date || self.get_start_date_of_payment
			# run payments every day for QA/dev
		if Rails.env.production? || Rails.env.test? || Rails.env.development?
			if sd.day == 1
				return sd + 15.days
			else
				return sd.beginning_of_month + 1.month
			end
		else
			return sd + 1.day
		end
	end


private


	def set_partner_to_bank_owner
		if self.partner_id.nil? && self.bank_id.present?
			self.partner = self.bank.owner
		end
	end


end

# == Schema Information
#
# Table name: payments
#
#  id             :integer         not null, primary key
#  start_date     :datetime
#  end_date       :datetime
#  auth_date      :datetime
#  conf_num       :string(255)
#  m_transactions :integer         default(0)
#  m_amount       :integer         default(0)
#  u_transactions :integer         default(0)
#  u_amount       :integer         default(0)
#  total          :integer         default(0)
#  paid           :boolean         default(FALSE)
#  partner_id     :integer
#  partner_type   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  l_transactions :integer         default(0)
#  l_amount       :integer         default(0)
#  at_user_id     :integer
#

