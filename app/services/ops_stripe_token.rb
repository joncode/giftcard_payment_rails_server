require 'stripe'

class OpsStripeToken
	include MoneyHelper
	include OpsStripeHelper

	attr_reader :response, :success, :request_id, :error, :error_message, :error_code, :error_key,
		:http_status, :customer_name, :token, :card_id, :ccy, :email, :card, :customer_id, :country, :brand

	def initialize args
		Stripe.api_key = STRIPE_SECRET
		puts 'OpsStripeToken' + args.inspect
		@token = args['stripe_id']
		@customer_id = args['stripe_user_id']
		@customer_name = args['origin']
		@card_id = args['id']
		@amount = args['amount'].to_i || 0
		@ccy = args['ccy']
		@email = args['nickname']
	end

	def tokenize
		return nil if @token.nil? || @customer_name.nil? || @email.nil?
		@response = Stripe::Customer.create(
			:source => @token,
			:description => "#{@customer_name} #{@email}",
			:email => @email
		)
		puts @response.inspect
		@customer_id = @response.id
		process_card_validation @response.sources.first
	rescue => e
		puts e.inspect
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