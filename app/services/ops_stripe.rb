require 'stripe'

class OpsStripe
	extend MoneyHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :http_status,
		:customer_id, :card_id
	STRIPE_SECRET = 'sk_test_UMvfuiV9aOOdq0H0xUeJWT3m'
	STRIPE_PUBLISH = 'pk_test_M2AJiAnTaOfisPLWXPFMc0dD'

	def initialize
		Stripe.api_key = STRIPE_SECRET
		@success = false
		@error = nil
		@error_message = nil
		@error_code = nil
		@http_status = 100
		@response = nil
		@request_id = nil
		@customer_id = nil
		@card_id = nil
	end

	def purchase token, amount_cents, ccy, unique_id, gift_id
			@response = Stripe::Charge.create(
				amount: amount_cents,
				currency: ccy.downcase,
				customer: token,
				description: "Charge for #{gift_id}",
				idempotency_key: unique_id
			)
			@response
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

	def tc
		{
			month: '04',
			year: '2019',
			number: '4000000000000101',
			ccy: 'USD',
			cvv: '233',
			zip: '90023',
			name: 'Testing Card',
			address_line: '900 S las Vegas Blvd',
		}.stringify_keys
	end

	def tokenize card_hsh, customer_id=nil
		src_obj = {
					object: 'card',
					exp_month: card_hsh["month"],
					exp_year: card_hsh["year"],
					number: card_hsh["number"],
					currency: card_hsh['ccy'].downcase,
					cvc: card_hsh["cvv"],
					address_zip: card_hsh['zip'],
					address_line1: card_hsh['address_line'],
					name: card_hsh["name"]
				}

		if customer_id
			customer = Stripe::Customer.retrieve(customer_id)
			@response = customer.sources.create(source: src_obj)
		else
			@response = Stripe::Customer.create(
				description: "Customer for #{card_hsh["name"]}",
				source: src_obj
			)
			process_customer_response @response
		end
	rescue => e
		process_error e
	end

	def process_customer_response r
		@customer_id = r.id
		@card_id = r.sources.first.id
		zip_check = (r.sources.first.address_zip_check == 'pass')
		address_check = (r.sources.first.address_line1_check == 'pass')
		cvc_check = (r.sources.first.cvc_check == 'pass')
		if !zip_check || !address_check
			validation_error
		elsif !cvc_check
			cvc_validation_error
		else
			process_success r
		end
		r
	end

	def process_success r
		@success = true
		@http_status = 200
	end

	def cvc_validation_error
		@success = false
		@error_message = 'Invalid CVC code'
		@error_code = 'cvc_error'
		@http_status = 400
	end

	def address_validation_error
		@success = false
		@error_message = 'Invalid address or postal code'
		@error_code = 'address_zip_error'
		@http_status = 400
	end

	def process_error e
		@error = e
		@success = false
		if e.respond_to?(:request_id)
			@error_message = e.message
			@request_id = e.request_id
			@error_code = e.code
			@http_status = e.http_status
		else
			@http_status = 500
			@error_code = "ops_stripe_error"
			@error_message = e.message
		end
		e
	end

end


