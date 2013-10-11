require 'authorize_net'

class Sale < ActiveRecord::Base

    if Rails.env.production?
            # real account
     	AUTHORIZE_API_LOGIN 	  = '9tp38Ga4CQ'
     	AUTHORIZE_TRANSACTION_KEY = '9EcTk32BHeE8279P'
     	GATEWAY 			      = :production
    elsif Rails.env.staging? || Rails.env.development?
            # test account
        AUTHORIZE_API_LOGIN       = '948bLpzeE8UY'
        AUTHORIZE_TRANSACTION_KEY = '7f7AZ66axeC386q7'
        GATEWAY                   = :sandbox
    end

 	attr_accessor :transaction, :credit_card, :response, :total
 	# NOTE - Revenue is a decimal value - gift.total is a string - converted in self.init below
 	# attr_accessible :card_id, :gift_id, :giver_id, :provider_id, :request_string, :response_string, :revenue, :status, :transaction_id

	belongs_to :provider
	belongs_to :giver, class_name: "User"
	belongs_to :gift
    #has_one :gift,   as: :payable
	#has_one    :order, through: :gift
	belongs_to :card

    validates_presence_of :gift_id, :giver_id, :resp_code

#### SALE PROCESS METHODS

    class << self

        def process gift
            sale = Sale.init gift
            sale.auth_capture
        end

    	def init gift
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

    end

### AUTHORIZE TRANSACTION METHODS

    def void_sale gift=nil
        gift      = self.gift if gift.nil?
        auth_obj  = authorize_net_aim_transaction
        @response = auth_obj.void(self.transaction_id)
        puts "HERE IS THE VOID ReSPONSE #{@response.inspect}"

        if @response.response_code == "1"
            if gift.status = "redeemed"

                gift.update_attributes({pay_stat: 'refunded' })
            else
                gift.update_attributes({pay_stat: "void"})
            end
            return @response.response_reason_text
        else
            @response.response_reason_text
        end

    end

	def auth_capture
        timer = Time.now
        puts "------- Charge Card Timer --------"
        if  Rails.env.test?
            @transaction = AuthTransaction.new
            @response    = AuthResponse.new
        else
            # 1 makes a transaction
            @transaction = authorize_net_aim_transaction
            # 2 makes a credit card
            card         = self.card
            @transaction.fields[:first_name] = card.first_name
    		@transaction.fields[:last_name]  = card.last_name

    		card.decrypt! CATCH_PHRASE

            @credit_card = authorize_net_aim_response(card)

            # 3 gets a response from auth.net
            @response 	 = @transaction.purchase(self.total, @credit_card)
        end
        end_time = ((Time.now - timer) * 1000).round(1)
        puts "------ Total Time | (#{end_time}ms) ------"
        add_gateway_data
	end

    def add_gateway_data
        puts "in add gateway data"
        self.transaction_id     = self.response.transaction_id
        self.resp_json          = self.response.fields.to_json
        raw_request             = self.transaction.fields
        card_num                = raw_request[:card_num]
        last_four               = "XXXX" + card_num[12..15]
        raw_request[:card_num]  = last_four
        self.req_json           = raw_request.to_json
        self.resp_code          = self.response.response_code.to_i
        self.reason_text        = self.response.response_reason_text
        self.reason_code        = self.response.response_reason_code.to_i
        self
    end

private

    def authorize_net_aim_transaction
        AuthorizeNet::AIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => GATEWAY)
    end

    def authorize_net_aim_response card
        AuthorizeNet::CreditCard.new(card.number, card.month_year)
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

