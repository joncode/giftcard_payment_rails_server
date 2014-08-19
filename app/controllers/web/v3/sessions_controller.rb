class Web::V3::SessionsController < MetalController

    before_action :authenticate_web_general

    def create
        login    = params["data"]

        if login["password"]
            user, password = normal_login login
        else
            user = facebook_login login
        end

        if user
            if user.not_suspended?
                if login["password"]
                    if user.authenticate(password)
                        success user.login_web_serialize
                    else
                    	payload = fail_web_payload("invalid_email")
                        fail_web payload
                        status = :not_found
                    end
                else
                    success user.login_web_serialize
                end
            else
                payload = fail_web_payload("suspended_user")
                fail_web payload
                status = :unauthorized
            end
        else
            if login["password"]
                payload = fail_web_payload("invalid_email")
            else
                payload = fail_web_payload("invalid_facebook")
            end
			fail_web payload
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