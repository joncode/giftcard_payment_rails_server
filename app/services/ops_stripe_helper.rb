module OpsStripeHelper

#	-------------
# :to_db, :process_card_validation, :process_card_success, :process_error, :unavailable_validations,
#  :address_validation_error, :cvc_validation_error, :set_ccy

	def to_db
		if @success
			@response.to_json
		else
			if @error.present?
				@error.to_json
			else
				{ error_key: @error_key, error_message: @error_message ,
					request_id: @request_id, error_code: @error_code }.to_json
			end
		end
	end

	def get_ccy country
		{'US' => 'USD', 'CA' => 'CAD', 'GB' => 'GBP'}[country]
	end

#	-------------

	def process_card_validation card
		# Note: @cvc_check_skip comes from the OpsStripe class that includes this module.
		@card_id = card.id
		@card = card
		@country = card.country
		@ccy = get_ccy(card.country)
		@brand = card.brand.downcase.gsub(' ', '_') if card.brand.respond_to?(:downcase)

		if !@cvc_check_skip && checks_passed?(card.cvc_check, card.address_zip_check, card.address_line1_check)
			process_card_success card
		elsif @cvc_check_skip && checks_passed?(card.address_zip_check, card.address_line1_check)
			# do nothing
		elsif check_failed?(card.address_zip_check) || check_failed?(card.address_line1_check)
			address_validation_error
		elsif check_failed?(card.cvc_check)
			cvc_validation_error
		else
			unavailable_validations
		end
		card
	rescue => err
		puts "[module OpsStripeHelper :: process_card_validation]  Error"
		puts " | card:   #{card.inspect}"
		puts " | message: #{err.message}"
		puts " | error:   #{err}"
		raise err
	end

#	-------------

	# Occasionally, Stripe will report that a certain check is unavailable or not performed.
	# These are not failures, so treat them as passing.  (Also assume a pass if there's no explicit fail)
	# Example: `address_zip_check` for Australian 4-digit zips was unavailable at the time of this addition.
	def check_passed?(check)
		check.nil? || %w[pass unavailable unchecked].include?(check.downcase)
	rescue => err
		puts "[module OpsStripeHelper :: check_passed?]  Error"
		puts " | check:   #{check.inspect}"
		puts " | message: #{err.message}"
		puts " | error:   #{err}"
		raise err
	end

	def checks_passed?(*checks)
		# Check each then & the results together
		checks.map{|check| check_passed?(check) }.reduce(&:&)
	rescue => err
		puts "[module OpsStripeHelper :: checks_passed?]  Error"
		puts " | checks:  #{checks.inspect}"
		puts " | message: #{err.message}"
		puts " | error:   #{err}"
		raise err
	end


	# Explicit failures only
	def check_failed?(check)
		check.present? && check.downcase == 'fail'
	rescue => err
		puts "[module OpsStripeHelper :: check_failed?]  Error"
		puts " | check:   #{check.inspect}"
		puts " | message: #{err.message}"
		puts " | error:   #{err}"
		raise err
	end

#	-------------

	def process_card_success card
		@success = true
		@http_status = 200
	end

	def process_error e
		@error = e
		@success = false
		@resp_code = 3
		if e.respond_to?(:request_id)
			@error_message = e.message
			@request_id = e.request_id
			if e.respond_to?(:code)
				@error_code = e.code
			else
				if e.message.match(/No such token/)
					@error_message = 'Card Upload Token has expired.  Please re-upload card'
					@error_code = 'card_upload_expired'
					@resp_code = 2
				else
					@error_code = 'invalid_request'
				end
			end
			@http_status = e.http_status
			@error_key = @error_code
			if @error_key == "card_declined"
				@resp_code = 2
			end
		else
			@http_status = 500
			@error_code = "ops_stripe_error"
			@error_message = e.message
			@error_key = :internal
		end
		e
	end

#	-------------

	def unavailable_validations
		@success = false
		@error_message = "Credit card company failed to validate this card. Please use another card."
		@error_code = 'unavailable_validations'
		@http_status = 402
		@error_key = :validation
		@resp_code = 3
	end

	def cvc_validation_error
		@success = false
		@error_message = "The card security code is incorrect."
		@error_code = 'incorrect_cvc'
		@http_status = 402
		@error_key = :cvc
		@resp_code = 3
	end

	def address_validation_error
		@success = false
		@error_message = 'Invalid address or postal code'
		@error_code = 'address_zip_error'
		@http_status = 402
		@error_key = :address
		@resp_code = 3
	end
end


