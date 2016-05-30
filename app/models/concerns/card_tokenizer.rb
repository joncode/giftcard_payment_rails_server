module CardTokenizer
    extend ActiveSupport::Concern

    def tokenize
		user = User.unscoped.find(self.user_id)
		transarmor_tokenize
    	if self.cim_token == nil
    		begin
		    	if user.cim_profile.present?
		    		add_payment_profile(user.cim_profile)
		    	else
		    		create_profile_and_payment_profile(user)
			    end
			rescue
				puts "\n\n\n----   Card #{self.id} -- does not have a user\n\n\n"
			end
		end
    end

	def transarmor_tokenize
    	card_hsh = {}
		card_hsh["first_name"] = self.first_name
		card_hsh["last_name"] = self.last_name
		card_hsh["number"] = self.decrypt!(CATCH_PHRASE).number
		card_hsh["month"] = self.month
		card_hsh["year"] = self.year
		card_hsh["cvv"] = self.csv
		r = OpsFirstData.tokenize card_hsh
		if r[:status] == 1
			self.update(trans_token: r[:data])
		else
			puts "------ Failed Transaction with First Data Transarmour Response: #{ r.inspect }--------------"
		end
	end

    def create_profile_and_payment_profile user
    	card_number = self.decrypt!(CATCH_PHRASE).number
		customer_id = user.obscured_id

		resp, ditto = PaymentGatewayCim.create_profile_with_payment_profile(self, card_number, customer_id)
		if resp.success?
			if self.update(cim_token: resp.payment_profile_ids[0]) && user.update(cim_profile: resp.profile_id)
				puts "==== card updated successfully with Profile ID: #{resp.profile_id}, Payment Profile ID: #{resp.payment_profile_ids[0]} ==="
			else
				puts "------ Active Record failed to save Auth.net resp. Response: #{ resp.inspect }--------------"
			end
		else
				# if this fails because the user.cim_profile already exists then save cim_profile on the user and re-call add_add_payment_profile
			if resp.response_reason_code == "E00039" || resp.match(/duplicate record with ID/)

                id_match     = resp.message_text.match(/\d+/)
                profile_id   = id_match.to_s

                if profile_id.length > 5
	                unless user.update(cim_profile: profile_id)
	                    # profile Id not persisted to user
	                    # spin of the resque to re-persist
	                    add_payment_profile profile_id
	                end
                else
                	profile_id = ""    # reset the bad profile_id

                	# did not get a profile_id from the match
                	# send an alert to server admin with response
                end
            else
                # another error
            end

			puts "------ Failed Transaction with Auth.net Response: #{ response.inspect }--------------"
			puts "------ profile id #{ response.profile_id if response.profile_id }--------------"
			puts "------ payment_profile_id #{ response.payment_profile_ids[0] if response.payment_profile_ids }--------------"
			puts "------ Ditto ID: #{ ditto.id } --------------"
		end
    end

    def add_payment_profile  cim_profile
    	card_number = self.decrypt!(CATCH_PHRASE).number

    	response, ditto = PaymentGatewayCim.add_payment_profile(self, card_number, cim_profile)
		if response.success?
			puts "------ Saving Payment Profile ID: #{response.payment_profile_id}--------------"
			self.update(cim_token: response.payment_profile_id)
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
