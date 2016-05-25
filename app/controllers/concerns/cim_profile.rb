module CimProfile
    extend ActiveSupport::Concern


    def get_cim_profile(user)
    		# has cim profile - return it
    	return user.cim_profile if user.cim_profile

    	profile_id = "" # return empty string if unsuccessful

        	# No Cim Profile ? go get one
        resp  = PaymentGatewayCim.create_customer_profile(user.obscured_id)

        if resp.success?

        	profile_id = resp.profile_id
            unless user.update(cim_profile: resp.profile_id)
                # profile_id not persisted to user
                # spin of the resque to re-persist
            end

        else
            if resp.response_reason_code == "E00039" || resp.match(/duplicate record with ID/)

                id_match     = resp.message_text.match(/\d+/)
                profile_id   = id_match.to_s

                if profile_id.length > 5
	                unless user.update(cim_profile: profile_id)
	                    # profile Id not persisted to user
	                    # spin of the resque to re-persist
	                end
                else
                	profile_id = ""    # reset the bad profile_id

                	# did not get a profile_id from the match
                	# send an alert to server admin with response
                end
            else
                # another error
            end
        end
        profile_id
    end

    def mobile_credentials_response(profile_id)
        # get the session token from Auth.net
        session_token = AUTHORIZE_TRANSACTION_KEY
        { "key" => AUTHORIZE_MOBILE_DEVICE, "token" => session_token, "profile_id" => profile_id }
    end

    def destroy_card(card, user)
        if card.cim_token
            PaymentGatewayCim.delete_payment_profile(card.cim_token, user.cim_profile, user.id)
        end
        card.destroy
    end

end


# Resque Job to add cim_profile to user that accepts a cim_profile
# Get other error situations from the auth.net documentation
# add the dittos to the PaymentGatewayCim request