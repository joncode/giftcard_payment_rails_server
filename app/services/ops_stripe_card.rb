require 'stripe'

class OpsStripeCard
	extend MoneyHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :card, :country, :ccy, :brand

	def initialize customer_id=nil, card_init=nil
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
		if card_init
			@card_init = stripe_hsh_with_card(card_init)
		else
			@card_init = nil
		end
	end


#	-------------

	def stripe_hsh_with_card card
		if Rails.env.production?
			@card_init = {	month: card.month,
				year: card.year,
				number: card.number,
				csv: card.csv,
				zip: card.zip,
				name: card.name,
				# address_line: card.address
			}
		else
			@card_init = tc
		end
	end

	def tokenize card_hsh=@card_init, customer_id=@customer_id
		card_hsh.stringify_keys!
		src_obj = {
				object: 'card',
				exp_month: card_hsh["month"],
				exp_year: card_hsh["year"],
				number: card_hsh["number"],
				cvc: card_hsh["csv"],
				address_zip: card_hsh['zip'],
				address_line1: card_hsh['address_line'],
				name: card_hsh["name"]
			}

		if customer_id
			begin
				customer = Stripe::Customer.retrieve(customer_id)
			rescue => e
				customer = nil
			end
		end

		if customer.present?
			@response = customer.sources.create(source: src_obj)
			process_card_validation @response
		else
			@response = Stripe::Customer.create(
				description: "Customer for #{card_hsh["name"]}",
				source: src_obj
			)
			@customer_id = @response.id
			process_card_validation @response.sources.first
		end
	rescue => e
		process_error e
	end

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

#	-------------  TEST CARDS

	def test_card_numbers
		tcs = { '4000008260000000' => 'GB card', '4000001240000000' => 'Canada Card', '4000000000000119' => 'processing error',
			'4000000000000069' => 'expired code', '4000000000000127' => 'incorrect_cvc', '4100000000000019' => 'fraud',
			'4000000000000002' => 'declined code', '4000000000000341' => 'cannot cahnge customer object',
			'4000000000000101' => 'cvc declined', '4000000000000044' => 'unavailable_validations',
			'4000000000000036' => 'zip fail', '4000000000000028' => 'address fail', '4000000000000010' => 'addresss and zip fail',
			'4000000000000093' => 'intl pricing different', '4000000000000077' => 'add to available balance',
			'3566002020360505' => 'jcb good', '3530111333300000' => 'jcb good 2', '38520000023237' => 'diners club good',
			'30569309025904' => 'diners club good 2', '6011000990139424' => 'discover good', '6011111111111117' => 'discover good 2',
			'371449635398431' => 'amex good', '378282246310005' => 'amex good 2', '5105105105105100' => 'MasterCard (prepaid)',
			'5200828282828210' => 'MasterCard (debit)', '5555555555554444' => 'mastercard', '4000056655665556' => 'visa debt',
			'4012888888881881' => 'visa good', '4242424242424242' => 'visa good 2' }
		number = tcs.keys.sample
		puts "\nOpsStripeCard - chosen #{tcs[number]} #{number}\n\n"
		number
	end

	def tc
		{
			month: '04',
			year: '2021',
			number: test_card_numbers,
			csv: '233',
			zip: '90023',
			name: 'Testing Random',
			address_line: '900 S las Vegas Blvd'
		}
	end
end


