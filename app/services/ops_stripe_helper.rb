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

	def set_ccy country
		{'US' => 'USD', 'CA' => 'CAD', 'GB' => 'GBP'}[country]
	end

#	-------------

	def process_card_validation card
		@card_id = card.id
		@card = card
		@country = card.country
		@ccy = set_ccy(card.country)
		@brand = card.brand.downcase.gsub(' ', '_') if card.brand.respond_to?(:downcase)
		if !@cvc_check_skip && (card.address_zip_check == 'pass') && (card.address_line1_check == 'pass') && (card.cvc_check == 'pass')
			process_card_success card
		elsif !@cvc_check_skip && (card.address_zip_check == 'pass') && (card.address_line1_check.nil?) && (card.cvc_check == 'pass')
			process_card_success card
		elsif !@cvc_check_skip && (card.address_zip_check.nil?) && (card.address_line1_check.nil?) && (card.cvc_check == 'pass')
			process_card_success card
		elsif @cvc_check_skip && (card.address_zip_check == 'pass') && (card.address_line1_check.nil?)
			# do nothing
		elsif @cvc_check_skip && (card.address_zip_check == 'pass') && (card.address_line1_check == 'pass')
			# do nothing
		elsif (card.address_zip_check == 'fail')
			address_validation_error
		elsif (card.address_line1_check == 'fail')
			address_validation_error
		elsif (card.cvc_check == 'fail')
			cvc_validation_error
		else
			unavailable_validations
		end
		card
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
				@error_code = 'invalid_request'
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


