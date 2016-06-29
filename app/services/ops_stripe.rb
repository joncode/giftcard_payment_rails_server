require 'stripe'

class OpsStripe
	include MoneyHelper
	include OpsStripeHelper
		# OpsStripeHelper = :to_db, :process_card_validation, :process_card_success, :process_error,
		#  :address_validation_error, :cvc_validation_error, :unavailable_validations, :set_ccy

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :ccy, :amount, :unique_id, :resp_code


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
		@resp_code = 0
	end

#	-------------

    def gateway_hash_response r=@response
        hsh = {}
       	set_response_code hsh
        hsh["resp_json"]       = to_db
        hsh["req_json"]        = @request.to_json
    	hsh["transaction_id"]  = @request_id
        if @resp_code == 1
        	hsh["revenue"] = display_money(cents: r.amount)
        else
        	hsh["revenue"] = display_money(cents: @amount)
        end
        hsh
    end

    def set_response_code hsh
        hsh["reason_code"] = 1
		hsh["resp_code"] = @resp_code
    	if @resp_code == 1
    		hsh["reason_text"] = "This transaction has been approved."
		else
			hsh["reason_text"] = @error_message
		end
    end

	def process_card_success card
		@request_id = @response.id
    	if @response.status == 'succeeded'
    		@success = true
    		@http_status = 200
    		@resp_code = 1
    	elsif @response.status == 'pending'
    		@success = false
    		@http_status = 201
    		@resp_code = 4
    		@error_message = 'Transaction pending approval'
    	else  # failed
    		@success = false
    		@http_status = 400
    		@resp_code = 2
    		@error_message = "Transaction failed."
		end
	end

#	-------------

	def purchase
		@request = {
			amount: @amount,
			currency: @ccy,
			customer: @customer_id,
			source: @card_id,
			description: "Purchase #{@unique_id}",
			idempotency_key: @unique_id
		}
		@response = Stripe::Charge.create(@request)
		process_card_validation @response.source
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



end


