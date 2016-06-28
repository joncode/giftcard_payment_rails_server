require 'stripe'

class OpsStripe
	extend MoneyHelper

	attr_accessor :response, :obj
	STRIPE_SECRET = 'sk_test_UMvfuiV9aOOdq0H0xUeJWT3m'
	STRIPE_PUBLISH = 'pk_test_M2AJiAnTaOfisPLWXPFMc0dD'

	def initialize
		Stripe.api_key = STRIPE_SECRET

		@response = nil
		@obj = nil
	end

	def purchase token, amount_cents, ccy
		Stripe::Charge.create(
			amount: amount_cents,
			currency: ccy.downcase,
			customer: token,
			description: "Charge for test@example.com",
			idempotency_key: "testing for this"
		)
	end

	def refund charge_id
		re = Stripe::Refund.create(charge: charge_id)
	end


#	-------------

	def tokenize card_hsh, ccy='USD', customer_id=nil
		src_obj = {
					object: 'card',
					exp_month: card_hsh["month"],
					exp_year: card_hsh["year"],
					number: card_hsh["number"],
					currency: ccy.downcase,
					cvc: card_hsh["cvv"],
					name: card_hsh["first_name"] + card_hsh["last_name"]
				}
		if customer_id
			customer = Stripe::Customer.retrieve(customer_id)
			customer.sources.create(source: src_obj)
		else
			Stripe::Customer.create(
				description: "Customer for #{card_hsh["first_name"] + card_hsh["last_name"]}",
				source: src_obj
			)
		end
	end


end


