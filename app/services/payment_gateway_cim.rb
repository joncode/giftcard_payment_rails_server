require 'authorize_net'

class PaymentGatewayCim             # charge , refund, cancel, void - instance methods

    extend PaymentGatewayStorage    # class methods to manage cards and users

    attr_accessor :transaction, :response
    attr_reader :amount, :profile_id, :payment_profile_id, :transaction_id, :unique_id

########   charge using tokenized card instance methods

    def initialize(args={})
        @amount             = args["amount"]
        @unique_id          = args["unique_id"]
        @transaction_id     = args["transaction_id"]
        @profile_id         = args["cim_profile"]
        @payment_profile_id = args["cim_token"]
    end

    def charge
        @transaction = authorize_net_cim_transaction
        @response    = @transaction.create_transaction_auth_capture(@amount, @profile_id, @payment_profile_id)
        gateway_hash_response
    end

    def self.response_json response
        {
            "message_code" => response.message_code,
            "message_text" => response.message_text,
            "profile" => response.profile
        }.to_json
    end

    def gateway_hash_response
        hsh = {}
        if self.response.direct_response.nil?   # inconsistent response from Auth.net
            puts "500 Internal HERE IS THE inconsistent response #{self.response.inspect}"
            hsh["transaction_id"]  = self.transaction_id
            message_code           = self.response.message_code
            hsh["resp_code"]       = message_code_to_resp_code(message_code)
            hsh["reason_text"]     = self.response.message_text
        else
            hsh["transaction_id"]  = self.response.direct_response.transaction_id
            hsh["resp_code"]       = self.response.direct_response.response_code
            hsh["reason_text"]     = self.response.direct_response.response_reason_text
        end
        hsh["resp_json"]       = PaymentGatewayCim.response_json(self.response)
        hsh["req_json"]        = self.transaction.fields.to_json
        hsh["reason_code"]     = 1
        hsh["revenue"]         = self.amount
        hsh
    end

    def authorize_net_cim_transaction
        t = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        if Rails.env.staging?
            puts "HERE IS THE CIM transaction #{t.inspect}"
        end
        t
    end

    def self.duplicate? message_code
        message_code == "E00039"
    end

    def message_code_to_resp_code message_code
        case message_code
        when "I00001" #Successful
            1
        when "E00027" #The transaction was unsuccessful
            2
        when "E00007" # invalid login credentials
            3
        when "E00039"  # duplicate profile exists
            4
        else          #Error/Failure
            3
        end
    end


end
