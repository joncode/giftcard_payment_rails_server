require 'authorize_net'

class Sale < ActiveRecord::Base
    include Email

        # real account
 	AUTHORIZE_API_LOGIN 	  = '9tp38Ga4CQ'
 	AUTHORIZE_TRANSACTION_KEY = '9EcTk32BHeE8279P'
 	GATEWAY 			      = :production

 	attr_accessor :transaction, :credit_card, :response, :total
 	# NOTE - Revenue is a decimal value - gift.total is a string - converted in self.init below
 	# attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction_id

	belongs_to :provider
	belongs_to :giver, class_name: "User"
	belongs_to :gift
	has_one    :order, through: :gift
	belongs_to :card

	before_create :add_gateway_data
  	after_create  :invoice_giver,    :if => :transaction_approved
  	after_create  :notify_receiver,  :if => :transaction_approved

### AUTHORIZE TRANSACTION METHODS

	def self.init gift
		puts "in Sale.init"
		sale_obj 		     = Sale.new
		sale_obj.card_id 	 = gift.credit_card
		sale_obj.gift_id 	 = gift.id
		sale_obj.giver_id 	 = gift.giver_id
		sale_obj.provider_id = gift.provider_id
		sale_obj.revenue 	 = BigDecimal(gift.grand_total)
		sale_obj.total 	     = gift.grand_total
		return sale_obj
	end

    def void_sale gift=nil
        gift      = self.gift if gift.nil?
        auth_obj  = AuthorizeNet::AIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => GATEWAY)
        @response = auth_obj.void(self.transaction_id)
        puts "HERE IS THE VOID ReSPONSE #{@response.inspect}"

        if @response.response_code == "1"
            # sale is voided
            # set gift to proper status
            if gift.status = "redeemed"
                new_status = "refund_cancel" || "cancel"
                gift.update_attribute(:status, new_status)
            else
                gift.update_attribute(:status, "refund_void")
            end
            return @response.response_reason_text
        else
            # gift unable to be voided
            @response.response_reason_text
        end

    end

	def auth_capture
		puts "in auth capture in Sale.rb"
        # 1 makes a transaction
        @transaction = AuthorizeNet::AIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => GATEWAY)
        # 2 makes a credit card
        card         = self.card
        @transaction.fields[:first_name] = card.first_name
		@transaction.fields[:last_name]  = card.last_name

		month 		 = "%02d" % card.month.to_i
		year 		 = card.year[2..3]
		card.decrypt! "Theres no place like home"
		card_number  = card.number
		month_year 	 = "#{month}#{year}"

        total_amount = self.total

        @credit_card = AuthorizeNet::CreditCard.new(card_number, month_year)

        # 3 gets a response from auth.net
        @response 	 = @transaction.purchase(total_amount, @credit_card)

	end

	def add_gateway_data
		puts "in add gateway data"
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
		puts "#{self.inspect}"
	end

	# def notify_receiver
	# 	gift = self.gift
 #      	if gift.receiver_email
 #        	puts "emailing the gift receiver for #{gift.id}"
 #        	# notify the receiver via email
 #        	user_id = gift.receiver_id.nil? ?  'NID' : gift.receiver_id
 #        	Resque.enqueue(EmailJob, 'notify_receiver', user_id , {:gift_id => gift.id, :email => gift.receiver_email})
 #      	end
 #    end

 #    def invoice_giver
 #    	gift = self.gift
 #        puts "emailing the gift giver for #{gift.id}"
 #        # notify the giver via email
 #        Resque.enqueue(EmailJob, 'invoice_giver', gift.giver_id , {:gift_id => gift.id})
 #    end

    def transaction_approved
    	# chek that sale transaction is approved
    	if self.resp_code == 1
    		return true
    	else
    		return false
    	end
    end

end
# == Schema Information
#
# Table name: sales
#
#  id             :integer         not null, primary key
#  gift_id        :integer
#  giver_id       :integer
#  card_id        :integer
#  provider_id    :integer
#  transaction_id :string(255)
#  revenue        :decimal(, )
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  resp_json      :text
#  req_json       :text
#  resp_code      :integer
#  reason_text    :string(255)
#  reason_code    :integer
#

