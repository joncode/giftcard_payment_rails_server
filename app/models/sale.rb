require 'authorize_net'

class Sale < ActiveRecord::Base
 	AUTHORIZE_API_LOGIN 	  = '7esX3XfuS5w'
 	AUTHORIZE_TRANSACTION_KEY = '3y9dLy3Pm37AK9qT'
 	GATEWAY 			      = :sandbox

 	attr_accessor :transaction, :credit_card, :response, :total
 	# NOTE - Revenue is a decimal value - gift.total is a string - converted in self.init below
 	# attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction_id
	
	belongs_to :provider	
	belongs_to :giver, class_name: "User"	
	has_one	   :gift
	has_one    :order, through: :gift
	belongs_to :card

	before_create :add_gateway_data	

### AUTHORIZE TRANSACTION METHODS

	def self.init gift
		sale_obj 		     = Sale.new
		sale_obj.card_id 	 = gift.credit_card
		sale_obj.gift_id 	 = gift.id
		sale_obj.giver_id 	 = gift.giver_id
		sale_obj.provider_id = gift.provider_id
		sale_obj.revenue 	 = gift.total
		sale_obj.total 	     = gift.total
		return sale_obj
	end

	def auth_capture
        # 1 makes a transaction
        @transaction = AuthorizeNet::AIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => GATEWAY)
        # 2 makes a credit card
		card 		 = self.card
		month 		 = card.month
		if month.length == 1
			month 	 = "0" + month
		end
		year 		 = card.year[2..3]
		card_number  = '4111111111111111'	
		month_year 	 = "#{month}#{year}" 
		total_amount =  self.total  
       
        @credit_card = AuthorizeNet::CreditCard.new(card_number, month_year)
        
        # populate the transaction with data
        @transaction.fields[:first_name] = card.first_name
		@transaction.fields[:last_name] = card.last_name

        # 3 gets a response from auth.net
        @response 	 = @transaction.purchase(total_amount, credit_card)

	end

	def add_gateway_data
		self.transaction_id    = self.response.fields[:transaction_id]
		self.response_string   = self.response.fields.to_json
		raw_request			   = self.transaction.fields
		card_num 			   = raw_request[:card_num]
		last_four			   = "XXXX" + card_num[12..15]
		raw_request[:card_num] = last_four
		self.request_string    = raw_request.to_json
		self.status			   = self.response.fields[:response_code]
	end

end
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

