require 'stripe'

class OpsStripe
	extend MoneyHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :card, :country, :ccy, :brand


	def initialize customer_id=nil
		Stripe.api_key = STRIPE_SECRET
		@success = false
		@error = nil
		@error_message = nil
		@error_key = nil
		@error_code = nil
		@http_status = 100
		@response = nil
		@request_id = nil
		@customer_id = customer_id
		@card_id = nil
		@card = nil
		@country = nil
		@ccy = nil
		@brand = nil
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


#	-------------

	def process_card_success r
		@success = true
		@http_status = 200
		@country = r.country
		@ccy = set_ccy r.country
		@brand = r.brand.downcase
	end

	def set_ccy country
		{'US' => 'USD', 'CA' => 'CAD', 'GB' => 'GBP'}[country]
	end

	def process_card_validation r
		@card_id = r.id
		@card = r
		if (r.address_zip_check == 'pass') && (r.address_line1_check == 'pass') && (r.cvc_check == 'pass')
			process_card_success r
		elsif (r.address_zip_check == 'pass') && (r.address_line1_check.nil?) && (r.cvc_check == 'pass')
			process_card_success r
		elsif (r.address_zip_check == 'fail')
			address_validation_error
		elsif (r.address_line1_check == 'fail')
			address_validation_error
		elsif (r.cvc_check == 'fail')
			cvc_validation_error
		else
			unavailable_validations
		end
		r
	end

	def unavailable_validations
		@success = false
		@error_message = "Credit card company failed to validate this card. Please use another card."
		@error_code = 'unavailable_validations'
		@http_status = 402
		@error_key = :validation
	end

	def cvc_validation_error
		@success = false
		@error_message = "The card security code is incorrect."
		@error_code = 'incorrect_cvc'
		@http_status = 402
		@error_key = :cvc
	end

	def address_validation_error
		@success = false
		@error_message = 'Invalid address or postal code'
		@error_code = 'address_zip_error'
		@http_status = 402
		@error_key = :address
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


