require 'authorize_net'

class Sale < ActiveRecord::Base
		# real account
 	AUTHORIZE_API_LOGIN 	  = '9tp38Ga4CQ'
 	AUTHORIZE_TRANSACTION_KEY = '9EcTk32BHeE8279P'
 	GATEWAY 			      = :production
 		# sandbox account
 	# AUTHORIZE_API_LOGIN 	  = '7esX3XfuS5w'
 	# AUTHORIZE_TRANSACTION_KEY = '3y9dLy3Pm37AK9qT'
 	# GATEWAY 			      = :sandbox
 	attr_accessor :transaction, :credit_card, :response, :total
 	# NOTE - Revenue is a decimal value - gift.total is a string - converted in self.init below
 	# attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction_id
	
	belongs_to :provider	
	belongs_to :giver, class_name: "User"	
	belongs_to :gift
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
        @transaction.fields[:first_name] = card.first_name
		@transaction.fields[:last_name]  = card.last_name
		card 		 = self.card
		month 		 = "%02d" % card.month
		year 		 = card.year[2..3]
		card.decrypt! "Theres no place like home"
		######### put in real credit card details when in production
		num = card.number
		num[2..12] = "11111111111"
		card_number  = "4427427042229494"	
		        # populate the transaction with data
        @transaction.fields[:first_name] = "Dave"
		@transaction.fields[:last_name]  = "Leibner"
		month = "03"
		year  = "16"
		######### 

		month_year 	 = "#{month}#{year}" 
		total_amount =  "0.45"  
       
        @credit_card = AuthorizeNet::CreditCard.new(card_number, month_year)
        
        # 3 gets a response from auth.net
        @response 	 = @transaction.purchase(total_amount, @credit_card)

	end

	def add_gateway_data
		self.transaction_id    	= self.response.transaction_id
		self.resp_json   		= self.response.fields.to_json
		raw_request			   	= self.transaction.fields
		card_num 			   	= raw_request[:card_num]
		last_four			   	= "XXXX" + card_num[12..15]
		raw_request[:card_num] 	= last_four
		self.req_json    	   	= raw_request.to_json
		self.resp_code		 	= self.response.response_code.to_i
		self.reason_text		= self.response.response_reason_text
		self.reason_code		= self.response.response_reason_code.to_i
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

