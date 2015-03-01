class Payment < ActiveRecord::Base

	belongs_to :partner,  polymorphic: true

	def affiliate
		self.partner
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

