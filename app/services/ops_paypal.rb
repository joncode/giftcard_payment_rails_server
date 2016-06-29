require 'paypal-sdk-rest'
include PayPal::SDK::REST

class OpsPaypal
	include MoneyHelper

	attr_accessor :response, :obj

	def initialize
		# @gateway = gateway
		@response = nil
		@obj = nil
	end

	def purchase token, amount_cents, ccy
		return nil if (token.blank? || ccy.blank? || amount_cents.to_i == 0)

		total = display_money cents: amount_cents

		@obj = Payment.new({
			intent: "sale",
			payer: {
				payment_method: "credit_card",
				funding_instruments: [
					{
						credit_card_token: { credit_card_id: token }
			    	}
			    ]
			},
			transactions: [
				{
					amount: { total: total, currency: ccy },
					description: "what to put here ?"
				}
			]
		})
		@response = @obj.create
		@obj
	end

#	-------------

	def tokenize card_hsh
		@c = CreditCard.new({

			:first_name => card_hsh["first_name"],
			:last_name => card_hsh["last_name"],
			:number => card_hsh["number"],
			:expire_month => card_hsh["month"],
			:expire_year => card_hsh["year"] ,
			:cvv2 => card_hsh["cvv"],
			:type => brand_to_type(card_hsh["brand"]),


		    # ###Address
		    # Base Address object used as shipping or billing
		    # address in a payment. [Optional]
		   # :billing_address => {
		   #   :line1 => "52 N Main ST",
		   #   :city => "Johnstown",
		   #   :state => "OH",
		   #   :postal_code => "1121",
		   #   :country_code => "US" }
		})
		@response = @c.create
		@c
	end

	def brand_to_type brand
		# must be visa, mastercard, amex, discover, maestro, or jcb)
		if brand == 'master'
			'mastercard'
		else
			brand
		end
	end


#	-------------

	def gateway
		@gateway ||= new_gateway
	end

	def new_gateway
		PayPal::SDK.configure(
		  :mode => "sandbox", # "sandbox" or "live"
		  :client_id => PAYPAL_CLIENT_ID,
		  :client_secret => PAYPAL_SECRET,
		  :ssl_options => { } )
	end

end


	# what is the correct phone number
		# 1-888-221-1161
		# 702-808-3283
		# 7245
	# is my account set up correctly
		# yes
	# can fraud test credit cards
		# https://www.paypal-techsupport.com/app/ask