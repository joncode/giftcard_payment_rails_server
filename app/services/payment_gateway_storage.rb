module PaymentGatewayStorage

    def create_customer_profile customer_id
        profile  = customer_profile_for customer_id
        response = gateway.create_profile(profile)
        Ditto.create_customer_profile(response, customer_id)
        return response
    end

    def create_profile_with_payment_profile card, card_number, customer_id
        payment_profile = payment_profile_for card, card_number
        profile         = customer_profile_for customer_id, payment_profile
        response        = gateway.create_profile(profile)
        ditto           = Ditto.tokenize_card(response, card.id)
        return response, ditto
    end

    def add_payment_profile card, card_number, cim_profile
        payment_profile = payment_profile_for card, card_number
        response        = gateway.create_payment_profile(payment_profile, cim_profile)
        ditto           = Ditto.tokenize_card(response, card.id)
        return response, ditto
    end

    def delete_payment_profile payment_profile_id, profile_id, user_id
        response        = gateway.delete_payment_profile(payment_profile_id, profile_id)
        Ditto.delete_card_token(response, user_id)
        return response
    end


private

    def customer_profile_for customer_id, payment_profile=nil
        if payment_profile
            AuthorizeNet::CIM::CustomerProfile.new(id: customer_id, payment_profiles: [payment_profile])
        else
            AuthorizeNet::CIM::CustomerProfile.new(id: customer_id)
        end
    end

    def payment_profile_for card, card_number
        auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
        AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)
    end

    def gateway
        AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
    end

end