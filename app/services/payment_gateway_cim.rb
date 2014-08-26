require 'authorize_net'

class PaymentGatewayCim

    attr_accessor :transaction, :response
    attr_reader :amount, :profile_id, :payment_profile_id, :transaction_id, :unique_id

    def initialize(args={})
        @amount             = args["amount"]
        @unique_id          = args["unique_id"]
        @transaction_id     = args["transaction_id"]
        @profile_id         = args["cim_profile"]
        @payment_profile_id = args["cim_token"]
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

    def self.create_profile card, card_number, customer_id
        auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
        payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)
        profile         = AuthorizeNet::CIM::CustomerProfile.new(id: customer_id, payment_profiles: [payment_profile])
        gateway  = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        response = gateway.create_profile(profile)
        ditto    = Ditto.tokenize_card(response, card.id)
        return response, ditto
    end

    def self.add_payment_profile card, card_number, cim_profile
        auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
        payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)
        gateway = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        response = gateway.create_payment_profile(payment_profile, cim_profile)
        ditto    = Ditto.tokenize_card(response, card.id)
        return response, ditto
    end

private

    def gateway_hash_response
        hsh = {}
        hsh["transaction_id"]  = self.transaction_id
        hsh["resp_json"]       = PaymentGatewayCim.response_json(self.response)
        hsh["req_json"]        = self.transaction.fields.to_json
        message_code           = self.response.message_code
        hsh["resp_code"]       = message_code_to_resp_code(message_code)
        hsh["reason_text"]     = self.response.message_text
        hsh["reason_code"]     = 1
        hsh["revenue"]         = self.amount
        hsh
    end

    def authorize_net_cim_transaction
        t = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
        puts "HERE IS THE CIM transaction #{t.inspect}"
        t
    end

    def message_code_to_resp_code message_code
        case message_code
        when "I00001"
            1
        when "E00027" #The transaction was unsuccessful
            2
        else
            3
        end
    end


end
