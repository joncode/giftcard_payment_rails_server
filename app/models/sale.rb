class Sale < ActiveRecord::Base
 	attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction
	
	belongs_to :provider	
	belongs_to :giver, class_name: "User"	
	has_one	   :gift
	has_one    :order, through: :gift
	belongs_to :card	


end
