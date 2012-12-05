# == Schema Information
#
# Table name: sales
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  giver_id        :integer
#  card_id         :integer
#  request_string  :string(255)
#  response_string :string(255)
#  status          :string(255)
#  provider_id     :integer
#  transaction_id  :string(255)
#  revenue         :decimal(, )
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

class Sale < ActiveRecord::Base
 	attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction
	
	belongs_to :provider	
	belongs_to :giver, class_name: "User"	
	has_one	   :gift
	has_one    :order, through: :gift
	belongs_to :card	


end
