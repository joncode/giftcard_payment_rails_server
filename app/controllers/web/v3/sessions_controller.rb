class Web::V3::SessionsController < MetalController

    before_action :authenticate_web_general

    def create
        login    = params["data"]
    	pn_token = login["pn_token"]

        if login["password"]
            user, password = normal_login login
        else
            user = facebook_login login
        end

        if user
            if user.not_suspended?
                if login["password"]
                    if user.authenticate(password)
                        user.pn_token = pn_token if pn_token
                        success user.login_web_serialize
                    else
                    	fail_hash = {
                    		error_type: "INVALID_CREDENTIALS",
                    		error_description: "We don't recognize that email and password combination"
                    	}
                        fail_web fail_hash
                        status = :not_found
                    end
                else
                    user.pn_token = pn_token if pn_token
                    success user.login_web_serialize
                end
            else
            	fail_hash = {
            		error_type: "UNAUTHORIZED_CREDENTIALS",
            		error_description: "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
            	}
                fail_web fail_hash
                status = :unauthorized
            end
        else
            if login["password"]
            	fail_hash = {
            		error_type: "INVALID_CREDENTIALS",
            		error_description: "We don't recognize that email and password combination"
            	}
            else
            	fail_hash = {
            		error_type: "INVALID_CREDENTIALS",
            		error_description: "We don't recognize that facebook account"
            	}
            end
			fail_web fail_hash
            status = :not_found
        end
        respond(status)
    end

private

    def facebook_login login
        facebook_id    = login["fb_user_id"]
        facebook_token = login["fb_token"]
        user_social    = UserSocial.includes(:user).where(type_of: 'facebook_id', identifier: facebook_id).references(:users).first
        if user_social
            return user_social.user
        else
            return nil
        end
    end

    def normal_login login
        email       = login["username"].strip.downcase
        password    = login["password"]
        user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: email).references(:users).first
        if user_social
            return user_social.user, password
        else
            return nil
        end
    end

end