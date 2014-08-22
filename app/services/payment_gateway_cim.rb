require 'authorize_net'

class PaymentGatewayCim

    attr_accessor :transaction, :credit_card, :response
    attr_reader   :first_name,  :last_name, :unique_id, :number, :month_year, :amount, :transaction_id, :cc_last_four

    def initialize(args={})
        @amount             = args["amount"]
        @unique_id          = args["unique_id"]
        @transaction_id     = args["transaction_id"]
        @profile_id         = args["profile_id"]
        @payment_profile_id = args["payment_profile_id"]
    end

    def charge
        @transaction = authorize_net_cim_transaction
        @response = @transaction.create_transaction_auth_capture(@amount, @profile_id, @payment_profile_id)
        gateway_hash_response
    end

    def self.response_json response
        { 
            "message_code" => response.message_code, 
            "message_text" => response.message_text, 
            "profile" => response.profile
        }.to_json
    end

private

    def gateway_hash_response
        hsh = {}
        hsh["transaction_id"]  = self.transaction_id
        raw_request            = self.transaction.fields
        hsh["resp_json"]       = PaymentGatewayCim.response_json(self.response)
        hsh["req_json"]        = raw_request.to_json
        hsh["resp_code"]       = self.response.response_code.to_i
        hsh["reason_text"]     = self.response.response_reason_text
        hsh["reason_code"]     = self.response.response_reason_code.to_i
        hsh["revenue"]         = self.amount
        hsh
    end

    def authorize_net_cim_transaction
        t = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        puts "HERE IS THE CIM transaction #{t.inspect}"
        t
    end

end
