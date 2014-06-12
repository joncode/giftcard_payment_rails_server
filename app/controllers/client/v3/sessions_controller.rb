class Client::V3::SessionsController < MetalController

    def create
        login    = params["data"]
        email    = login["username"].strip.downcase
        password = login["password"]
    	pn_token = login["pn_token"]
        if user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: email).references(:users).first
            @user = user_social.user
            if @user.not_suspended?
                if @user.authenticate(password)
                    @user.pn_token = pn_token if pn_token
                    success @user.login_client_serialize
                else
                    fail "Invalid email/password combination"
                    status = :not_found
                end
            else
                fail "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
                status = :unauthorized
            end
        else
            fail "Invalid email/password combination"
            status = :not_found
        end
        respond(status)
    end

end