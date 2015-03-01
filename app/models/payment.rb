class Payment < ActiveRecord::Base

	has_many :registers
	belongs_to :partner,  polymorphic: true

	def affiliate
		self.partner
	end

	def self.get_start_date_of_payment
		now = DateTime.now.utc
			# run payments every day for QA/dev
		if Rails.env.production?
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
		sd = start_date || self.get_start_date_of_payment
			# run payments every day for QA/dev
		if Rails.env.production?
			if sd.day == 1
				return sd + 15.days
			else
				return sd.beginning_of_month + 1.month
			end
		else
			return sd + 1.day
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
#  m_transactions :integer
#  m_amount       :integer
#  u_transactions :integer
#  u_amount       :integer
#  total          :integer
#  paid           :boolean
#  partner_id     :integer
#  partner_type   :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

