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
