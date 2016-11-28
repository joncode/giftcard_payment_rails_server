require 'stripe'

class OpsStripeToken
	include MoneyHelper
	include OpsStripeHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_name, :token, :card_id, :ccy

	def initialize args
		Stripe.api_key = STRIPE_SECRET
		@token = args['stripe_id']
		@customer_id = args['stripe_user_id']
		@customer_name = args['origin']
		@card_id = args['id']
		@amount = args['amount'].to_i || 0
		@ccy = args['ccy']
	end

	def upload
		return nil if @token.nil? || @customer_name.nil? || @card_id.nil?
		@response = Stripe::Customer.create(
			:source => @token,
			:description => "#{@customer_name} - #{@card_id}"
		)
	rescue => e
		process_error e
	end

	def charge_token
		return nil if @customer_id.nil? || @ccy.nil? || @amount == 0
		@response = Stripe::Charge.create(
			:amount   => @amount,
			:currency => @ccy,
			:customer => @customer_id
		)
	rescue => e
		process_error e
	end

end