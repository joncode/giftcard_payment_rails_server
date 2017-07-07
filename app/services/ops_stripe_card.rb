require 'stripe'

class OpsStripeCard
	include MoneyHelper
	include OpsStripeHelper
		# OpsStripeHelper = :to_db, :process_card_validation, :process_card_success, :process_error,
		#  :address_validation_error, :cvc_validation_error, :unavailable_validations, :set_ccy

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :card, :country, :ccy, :brand,
		:description, :email, :first_name, :last_name, :phone, :resp_code

	def initialize customer_id=nil, card_init=nil
		Stripe.api_key = STRIPE_SECRET
		Stripe.api_version = "2017-06-05"
		@success = false
		@http_status = 100
		@customer_id = customer_id
		@cvc_check_skip = false
		if card_init
			@ccy = card_init.ccy if card_init.respond_to?(:ccy)
			@card_init = stripe_hsh_with_card(card_init)
		end
	end

	def add_customer= user
		@email = user.email
		@first_name = user.first_name
		@last_name = user.last_name
		@phone = user.phone
		@description = "ItsOnMe-#{user.id}"
	end

	def stripe_hsh_with_card card
		if Rails.env.production?
			@card_init = {	month: card.month,
				year: card.year,
				number: card.number,
				csv: card.csv,
				zip: card.zip,
				name: card.name
				# address_line: card.address
			}
		else
			@card_init = tc
		end
	end

#	-------------

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

		@description = "Customer for #{card_hsh['name']}" if @description.nil?

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
				description: @description,
				source: src_obj,
				email: @email,
				metadata: {
					first_name: @first_name,
					last_name: @last_name,
					card_name: card_hsh["name"],
					phone: @phone,
					currency: @ccy
				}
			)

			@customer_id = @response.id
			process_card_validation @response.sources.first
		end
	rescue => e
		process_error e
	end

#	-------------


#	-------------  TEST CARDS

	def test_card_numbers
		tcs = { '4000008260000000' => 'GB card', '4000001240000000' => 'Canada Card', '4000000000000119' => 'processing error',
			'4000000000000069' => 'expired code', '4000000000000127' => 'incorrect_cvc', '4100000000000019' => 'fraud',
			'4000000000000002' => 'declined code', '4000000000000341' => 'cannot change customer object',
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

	def random
		{
			month: '04',
			year: '2021',
			number: '6011000990139424',
			csv: '233',
			zip: '90023',
			name: 'Testing Random',
			address_line: '900 S las Vegas Blvd'
		}
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


