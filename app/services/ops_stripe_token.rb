require 'stripe'

class OpsStripeToken
	include MoneyHelper
	include OpsStripeHelper

	attr_accessor :response, :success, :request_id, :error, :error_message, :error_code, :error_key, :h,
		:http_status, :customer_name, :token, :card_id, :ccy, :email, :card, :customer_id, :country, :brand

	#  'stripe_id', 'stripe_user_id', 'id', 'amount', 'ccy', 'origin', 'nickname', 'email'

	def initialize args, user=nil
		Stripe.api_key = STRIPE_SECRET
		Stripe.api_version = "2017-06-05"
		puts 'OpsStripeToken' + args.inspect

		h = args.stringify_keys

		@token = h['stripe_id']
		@card_id = h['id']
		@amount = h['amount'].to_i || 0
		@ccy = h['ccy']
		if user
			@email = user.email
			@customer_name = user.name
			@customer_id = user.stripe_id || h['stripe_user_id']
		else
			@customer_id = h['stripe_user_id']
			@customer_name = h['origin']
			@email = h['nickname'] || h['email']
		end
	end

	def success?
		@success
	end

#   -------------

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

	def self.charge_card card_obj, desc="ItsOnMe charge"
		return nil if card_obj.nil?
		@response = Stripe::Charge.create(
			:amount   => card_obj.amount,
			:description => desc,
			:source => card_obj.stripe_id,
			:currency => card_obj.ccy
		)
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
		puts e.inspect
		process_error e
	end

#   -------------

	def self.create_subscription(stripe_user_id, plan_id)
        request = {
            :customer => stripe_user_id,
            :items => [{
                :plan => plan_id,
            }]
        }

        @response = Stripe::Subscription.create(request)

    rescue => e
    	puts e.inspect
        process_error e
	end

	def self.cancel_subscription subscription_id
        sub = Stripe::Subscription.retrieve(subscription_id)
        sub.delete
    rescue => e
    	puts e.inspect
        process_error e
    end


end