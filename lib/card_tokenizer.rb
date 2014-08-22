require 'authorize_net'

module CardTokenizer

	def self.tokenize_all
		cards = Card.where(cim_token: nil)
		cards.count
		puts "============== Starting Group Tokenization - Untokenized Cards: #{cards.count} =============="
		cards.each do |card|
			CardTokenizer.tokenize card.id
		end
		cards_after = Card.where(cim_token: nil).count
		puts "============== Ending Group Tokenization - Untokenized Cards: #{cards_after_count} =============="
	end

    def self.tokenize card_id
    	card = Card.find(card_id)
    	if card.cim_token.present? && card.cim_token.length > 3
	    	user = card.user
	    	if user.cim_token.present?
	    		CardTokenizer.add_payment_profile(card_id, user.cim_token)
	    	else
	    		CardTokenizer.create_profile_and_payment_profile(card_id)
		    end
		end
    end

    def self.create_profile_and_payment_profile card_id
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number
    	user        = card.user
		cust_id     = user.obscured_id

		auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
		payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)
		profile         = AuthorizeNet::CIM::CustomerProfile.new(id: cust_id, payment_profiles: [payment_profile])

		gateway  = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
		response = gateway.create_profile(profile)
		ditto    = Ditto.tokenize_card(response, card_id)

		if response.success?
			if card.update(cim_token: response.payment_profile_ids[0]) && user.update(cim_token: response.profile_id)
				puts "==== card updated successfully with Profile ID: #{response.profile_id}, Payment Profile ID: #{response.payment_profile_ids[0]} ==="
			else
				puts "------ Active Record failed to save Auth.net response. Response: #{ response.inspect }--------------"
			end
		else
			puts "------ Failed Transaction with Auth.net Response: #{ response.inspect }--------------"
			puts "------ profile id #{ response.profile_id if response.profile_id }--------------"
			puts "------ payment_profile_id #{ response.payment_profile_ids[0] if response.payment_profile_ids }--------------"
			puts "------ Ditto ID: #{ ditto.id } --------------"
		end
    end

    def self.add_payment_profile card_id, user_cim_token
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number

		auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
		payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)

    	gateway = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
    	response = gateway.create_payment_profile(payment_profile, user_cim_token)
		if response.success?
			puts "------ Saving Payment Profile ID: #{response.payment_profile_id}--------------"
			card.update(cim_token: response.payment_profile_id)
		else
			puts "------ Unable to update card Auth.net Response: #{response.inspect}--------------"
		end
	end

    def self.get_profile profile_id
		gateway  = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
		response = gateway.get_profile(profile_id)
		if response.success?
			puts "------ Success Auth.net Response: #{response.inspect}--------------"
			puts "------ Success Auth.net Response: #{response.profile}--------------"
		else
			puts "------ Unable to get profile Response: #{response.inspect}--------------"
		end
    end

end