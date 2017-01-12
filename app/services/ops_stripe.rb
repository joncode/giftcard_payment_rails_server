require 'stripe'

class OpsStripe
	include MoneyHelper
	include OpsStripeHelper
		# OpsStripeHelper = :to_db, :process_card_validation, :process_card_success, :process_error,
		#  :address_validation_error, :cvc_validation_error, :unavailable_validations, :set_ccy

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_id, :card_id, :ccy, :amount, :unique_id, :resp_code, :ccy


	def initialize cc_hsh={}
		Stripe.api_key = STRIPE_SECRET
		@customer_id = cc_hsh['stripe_user_id']
		@card_id = cc_hsh['stripe_id']
		@ccy = cc_hsh['ccy'].downcase if cc_hsh['ccy'].respond_to?(:downcase)
		@amount = currency_to_cents(cc_hsh['amount']) if cc_hsh['amount']
		@unique_id = cc_hsh['unique_id']
		@cvc_check_skip = true
		@success = false
		@http_status = 100
		@resp_code = 0
	end

    def add_customer= user
        @email = user.email
        @first_name = user.first_name
        @last_name = user.last_name
        @phone = user.phone
    end

    def ccy= ccy='USD'
        @ccy = ccy
    end

#	-------------

	def purchase
		@request = {
			amount: @amount,
			currency: @ccy,
			customer: @customer_id,
			source: @card_id,
			description: "Gift-Purchase-#{@unique_id}",
			idempotency_key: @unique_id,
            metadata: {
                first_name: @first_name,
                last_name: @last_name,
                email: @email,
                phone: @phone,
                currency: @ccy
            }
		}
		@response = Stripe::Charge.create(@request)
		process_charge_success @response.source
		@response
	rescue => e
		process_error e
	end

	def refund charge_id, amount=nil
		@request = { charge: charge_id }
        @request[:amount] = amount.to_i if amount.to_i > 0
		@response = Stripe::Refund.create(@request)
		process_refund_response
		@response
	rescue => e
		process_error e
	end

    def retrieve transaction_id
        if transaction_id[0..2] == 're_'
            @request = { refund: transaction_id }
            @response = Stripe::Refund.retrieve(id: transaction_id, expand: ['balance_transaction'])
        else
            @request = { charge: transaction_id }
            @response = Stripe::Charge.retrieve(id: transaction_id, expand: ['balance_transaction'])
        end
    end

#	-------------

    def gateway_hash_response r=@response
        hsh = {}
       	set_response_code hsh
       	hsh['gateway'] = 'stripe'
        hsh["resp_json"]       = to_db
        hsh["req_json"]        = @request.to_json
    	hsh["transaction_id"]  = @request_id
        if @resp_code == 1
        	hsh["revenue"] = display_money(cents: r.amount, ccy: @ccy)
        else
        	hsh["revenue"] = display_money(cents: @amount, ccy: @ccy)
        end
        puts hsh.inspect unless Rails.env.production?
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

    def process_refund_response
		@request_id = @response.id
    	if @response.status == 'succeeded'
    		@success = true
    		@http_status = 200
    		@resp_code = 1
    	elsif @response.status == 'pending'
    		@success = true
    		@http_status = 200
    		@resp_code = 1
    		@error_message = 'Transaction pending approval'
    		OpsTwilio.text_devs msg: "PENDING ON STRIPE #{@request_id}"
    	else  # failed
    		@success = false
    		@http_status = 400
    		@resp_code = 2
    		@error_message = "Transaction failed."
		end
    end

	def process_charge_success card
		@request_id = @response.id
    	if @response.status == 'succeeded'
    		@success = true
    		@http_status = 200
    		@resp_code = 1
    	elsif @response.status == 'pending'
    		@success = true
    		@http_status = 200
    		@resp_code = 1
    		@error_message = 'Transaction pending approval'
    		OpsTwilio.text_devs msg: "PENDING ON STRIPE #{@request_id}"
    	else  # failed
    		@success = false
    		@http_status = 400
    		@resp_code = 2
    		@error_message = "Transaction failed."
    		process_card_validation card
		end
	end




#	-------------



end


