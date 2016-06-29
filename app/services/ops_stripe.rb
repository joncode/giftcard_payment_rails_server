require 'stripe'

class OpsStripe
	include MoneyHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :ccy, :amount, :unique_id


	def initialize cc_hsh
		Stripe.api_key = STRIPE_SECRET
		@customer_id = cc_hsh['stripe_user_id']
		@card_id = cc_hsh['stripe_id']
		@ccy = cc_hsh['ccy'].downcase
		@amount = currency_to_cents(cc_hsh['amount'])
		@unique_id = cc_hsh['unique_id']
		@success = false
		@error = nil
		@error_message = nil
		@error_key = nil
		@error_code = nil
		@http_status = 100
		@response = nil
		@request_id = nil
	end

	def purchase
		@response = Stripe::Charge.create(
			amount: @amount,
			currency: @ccy,
			customer: @customer_id,
			source: @card_id,
			description: "Charge for #{@unique_id}",
			idempotency_key: @unique_id
		)
		process_card_success @response
	rescue => e
		process_error e
	end

	def refund charge_id
		@response = Stripe::Refund.create(charge: charge_id)
		@success = true
	rescue => e
		process_error e
	end


#	-------------


#	-------------

	def process_card_success r
		@success = true
		@http_status = 200
	end

	def process_error e
		@error = e
		@success = false
		if e.respond_to?(:request_id)
			@error_message = e.message
			@request_id = e.request_id
			if e.respond_to?(:code)
				@error_code = e.code
			else
				@error_code = 'invalid_request'
			end
			@http_status = e.http_status
			@error_key = @error_code
		else
			@http_status = 500
			@error_code = "ops_stripe_error"
			@error_message = e.message
			@error_key = :internal
		end
		e
	end

end


