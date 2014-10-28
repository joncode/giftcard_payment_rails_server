class Client::V3::SessionsController < MetalController

    def create
        login    = params["data"]
    	pn_token = login["pn_token"] || nil
        platform = login["platform"] || nil

        if login["password"]
            user, password = normal_login login
        else
            user = facebook_login login
        end


        if user
            if user.not_suspended?
                if login["password"]
                    if user.authenticate(password)
                        user.session_token_obj =  SessionToken.create_token_obj(user, platform, pn_token)
                        success user.login_client_serialize
                    else
                        fail "Invalid email/password combination"
                        status = :not_found
                    end
                else
                    user.pn_token = pn_token if pn_token
                    success user.login_client_serialize
                end
            else
                fail "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
                status = :unauthorized
            end
        else
            if login["password"]
                fail "Invalid email/password combination"
            else
                fail "facebook account not found"
            end
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