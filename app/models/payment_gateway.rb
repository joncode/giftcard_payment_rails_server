require 'authorize_net'

class PaymentGateway

    attr_accessor :transaction, :credit_card, :response
    attr_reader   :first_name,  :last_name,   :unique_id, :number, :month_year, :amount, :transaction_id

    def initialize(args={})
        @first_name     = args["first_name"]
        @last_name      = args["last_name"]
        @number         = args["number"]
        @month_year     = args["month_year"]
        @amount         = args["amount"]
        @unique_id      = args["unique_id"]
        @transaction_id = args["transaction_id"]
    end

    def charge

        # required => number, month_year, first_name, last_name, amount
        # optional => unique_id

            # 1 makes a transaction
        @transaction = authorize_net_aim_transaction
        @transaction.fields[:first_name] = @first_name
        @transaction.fields[:last_name]  = @last_name
        @transaction.fields[:po_num]     = @unique_id if @unique_id

            # 2 makes a credit card
        @credit_card = authorize_net_credit_card(@number, @month_year)

            # 3 gets a response from auth.net
        @response    = @transaction.purchase(@amount, @credit_card)
        gateway_hash_response
    end

    def void
            # 1 makes a transaction
        # @transaction = authorize_net_aim_transaction

        #     # 2 gets a response from auth.net
        # @response = @transaction.void(transaction_id)
    end

private

    def gateway_hash_response
        hsh = {}
        hsh["transaction_id"]  = self.response.transaction_id
        hsh["resp_json"]       = self.response.fields.to_json
        raw_request            = self.transaction.fields
        card_num               = raw_request[:card_num]
        last_four              = "XXXX" + card_num[12..15]
        raw_request[:card_num] = last_four
        hsh["req_json"]        = raw_request.to_json
        hsh["resp_code"]       = self.response.response_code.to_i
        hsh["reason_text"]     = self.response.response_reason_text
        hsh["reason_code"]     = self.response.response_reason_code.to_i
        hsh["revenue"]         = self.response.fields[:amount]
        hsh
    end

    def authorize_net_aim_transaction
        t = AuthorizeNet::AIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        puts "HERE IS THE AIM transaction #{t.inspect}"
        t
    end

    def authorize_net_credit_card number, month_year
        AuthorizeNet::CreditCard.new(number, month_year)
    end

end


#!/usr/bin/env ruby

# require 'rubygems'
# require 'active_merchant'

# Since this is a sample, use a hard-coded sandbox setup -
# you'll need to plug in your sandbox credentials.
# ActiveMerchant::Billing::Base.mode = :test
# SampleGateway = ActiveMerchant::Billing::AuthorizeNetGateway.new(
#   :login    => 'YOUR_SANDBOX_LOGIN_ID',
#   :password => 'YOUR_SANDBOX_TRANSACTION_KEY'
# )

# Our unified refund operation would likely go onto some kind of
# "model" or biz object that represents a purchase in your system.
# Since this is a sample, we'll just mock it up as a struct with the
# bare minimum required info.
# class Transaction < Struct.new( :transaction_id, :amount_charged, :cc_last_four )

#   # We'll raise this exception in the case of an unsettled credit.
#   class UnsettledCreditError < RuntimeError
#     UNSETTLED_CREDIT_RESPONSE_REASON_CODE = '54'

#     def self.match?( response )
#       response.params['response_reason_code'] == UNSETTLED_CREDIT_RESPONSE_REASON_CODE
#     end
#   end

#   def initialize( transaction_id, amount_charged, cc_last_four )
#     self.transaction_id = transaction_id
#     self.amount_charged = amount_charged
#     self.cc_last_four   = cc_last_four
#   end

#   def refund( amount )
#     if amount != self.amount_charged
#       # Different amounts: only a CREDIT will do
#       response = SampleGateway.credit(
#         amount,
#         self.transaction_id,
#         :card_number => self.cc_last_four
#       )
#       if UnsettledCreditError.match?( response )
#         raise UnsettledCreditError
#       end
#     else
#       # Same amount: try a VOID first, falling back to CREDIT if that fails
#       response = SampleGateway.void( self.transaction_id )

#       if !response.success?
#         response = SampleGateway.credit(
#           amount,
#           self.transaction_id,
#           :card_number => self.cc_last_four
#         )
#       end
#     end

#     response
#   end

# end

# # Let's include a little bit of code to exercise our new operation; if
# # you actually want to be able to do the CREDIT, you'll need to run a
# # transaction and wait for it to settle, then modify the code to have
# # that transaction id. Since we're just working with a purchase that
# # was made moments ago, it won't have settled, and we'll always end up
# # failing the partial refunding and doing the full refund with a VOID.
# credit_card = ActiveMerchant::Billing::CreditCard.new(
#   :number     => '4111111111111111',
#   :month      => 1,
#   :year       => 2015,
# )
# charge_amount = rand(1000) + 10 # Random amount to avoid dupe detection

# response = SampleGateway.purchase( charge_amount, credit_card )
# puts "Initial purchase: #{response.message}"
# exit 1 unless response.success?

# transaction_biz_object = Transaction.new(
#   response.params['transaction_id'],
#   charge_amount,
#   credit_card.number[-4..-1]
# )

# partial_refund_amount = charge_amount - 9
# begin
#   response = transaction_biz_object.refund( partial_refund_amount )
#   puts "Partial refund: #{response.message}"
# rescue Transaction::UnsettledCreditError
#   puts "Partial refund: Must do full refund then rerun for the correct amount."
# end

# response = transaction_biz_object.refund( charge_amount )
# puts "Full refund: #{response.message}"
