require 'authorize_net'

module CardTokenizer

	def self.tokenize_all
		cards = Card.where(payment_profile_id: nil)
		cards.count
		puts "============== Starting Group Tokenization - Untokenized Cards: #{cards.count} =============="
		cards.each do |card|
			CardTokenizer.tokenize card.id
		end
		cards_after = Card.where(payment_profile_id: nil).count
		puts "============== Ending Group Tokenization - Untokenized Cards: #{cards_after_count} =============="
	end

    def self.tokenize card_id
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number
    	user        = card.user
    	cust_id     = user.obscured_id

		auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
		payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)
		profile         = AuthorizeNet::CIM::CustomerProfile.new(id: cust_id,    payment_profiles: [payment_profile])

		gateway  = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)
		response = gateway.create_profile(profile)
		if response.success?
			puts "------ Saving Profile ID: #{response.profile_id}--------------"
			card.update(
				profile_id: response.profile_id,
				payment_profile_id: response.payment_profile_ids[0])
		else
			puts "------ Unable to update card Auth.net Response: #{response.inspect}--------------"
			puts "------ profile id #{response.profile_id}--------------"
			puts "------ payment_profile_id #{response.payment_profile_ids[0]}--------------"
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

    def self.add_payment_profile card_id, profile_id
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number

		auth_net_card   = AuthorizeNet::CreditCard.new(card_number, card.month_year)
		payment_profile = AuthorizeNet::CIM::PaymentProfile.new(payment_method: auth_net_card)

    	gateway = AuthorizeNet::CIM::Transaction.new(AUTHORIZE_API_LOGIN, AUTHORIZE_TRANSACTION_KEY, :gateway => AUTH_GATEWAY)	
    	response = gateway.create_payment_profile(payment_profile, profile_id)
		if response.success?
			puts "------ Saving Payment Profile ID: #{response.payment_profile_id}--------------"
			card.update(
				profile_id: profile_id,
				payment_profile_id: response.payment_profile_id)
		else
			puts "------ Unable to update card Auth.net Response: #{response.inspect}--------------"
		end
	end

end