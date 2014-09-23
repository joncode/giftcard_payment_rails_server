module CardTokenizer
    extend ActiveSupport::Concern

    def tokenize
    	if self.cim_token == nil
    		begin
	    		user = User.unscoped.find(self.user_id)
		    	if user.cim_profile.present?
		    		add_payment_profile(self.id, user.cim_profile)
		    	else
		    		create_profile_and_payment_profile(self.id)
			    end
			rescue
				puts "\n\n\n----   Card #{card.id} -- does not have a user\n\n\n"
			end
		end
    end

private

    def create_profile_and_payment_profile card_id
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number
    	user        = card.user
		customer_id = user.obscured_id

		response, ditto = PaymentGatewayCim.create_profile_with_payment_profile(card, card_number, customer_id)
		if response.success?
			if card.update(cim_token: response.payment_profile_ids[0]) && user.update(cim_profile: response.profile_id)
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

    def add_payment_profile card_id, cim_profile
    	card        = Card.find(card_id)
    	card_number = card.decrypt!(CATCH_PHRASE).number

    	response, ditto = PaymentGatewayCim.add_payment_profile(card, card_number, cim_profile)
		if response.success?
			puts "------ Saving Payment Profile ID: #{response.payment_profile_id}--------------"
			card.update(cim_token: response.payment_profile_id)
		else
			puts "------ Unable to update card Auth.net Response: #{response.inspect}--------------"
			puts "------ Ditto ID: #{ ditto.id } --------------"
		end
	end

    def get_profile profile_id
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