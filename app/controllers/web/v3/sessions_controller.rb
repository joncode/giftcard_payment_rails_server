class Web::V3::SessionsController < MetalCorsController

    before_action :authentication_no_token

    def create
        login_params = params["data"]

        if login_params['authReponse']
            login_params['authResponse'] = login_params['authReponse']
        end

        if login_params["password"] && login_params["username"]
            user = normal_login login_params
        elsif login_params["authResponse"] || login_params["accessToken"]
            resp = oauth_facebook_login login_params
            puts "\n (12) Here is oauth facebook login #{resp}\n"
            user = resp['user'] if resp['success']
        else
            user = facebook_login login_params
        end

        if user
            if user.not_suspended?
                user.session_token_obj =  SessionToken.create_token_obj(user, 'www', nil, @current_client, @current_partner)
                # @current_client.content = user --- in Resque in create_token_obj
                SessionBeginJob.perform(@current_client.id, user)
                success user.login_client_serialize

            else
                fail_web fail_web_payload("suspended_user")
                status = :unauthorized
            end
        else
            puts "\n (30) Here is the resp of things #{resp}\n" if resp
            if login_params["password"] && login_params["username"]
                fail_web fail_web_payload("invalid_email")
            elsif login_params["authResponse"] || login_params["accessToken"]
                if resp['error']
                    fail_web fail_web_payload(resp['error'])
                else
                    fail_web fail_web_payload('facebook login error')
                end
            else
                fail_web fail_web_payload('facebook login error')
            end
        end
        respond(status)
    end


private

    def oauth_facebook_login login_params
        token = login_params['accessToken'] || login_params['authResponse']['accessToken']
        begin
            graph = Koala::Facebook::API.new(token, FACEBOOK_APP_SECRET)
            profile = graph.get_object("me")
        rescue
            graph = Koala::Facebook::API.new(token)
            profile = graph.get_object("me")
        end

        puts "Here is the profile response #{profile}"
        OpsFacebook.login(token, profile)
    end


    def facebook_login login_params
        facebook_id    = login_params["fb_user_id"]
        facebook_token = login_params["fb_token"]
        user_social    = UserSocial.includes(:user).where(type_of: 'facebook_id', identifier: facebook_id).references(:users).first
        if user_social
            return user_social.user
        else
            return nil
        end
    end

    def normal_login login_params
        email       = login_params["username"].strip.downcase
        user_social = UserSocial.includes(:user).where(type_of: 'email', identifier: email).references(:users).first

        if user_social
            user = user_social.user
            if user && user.authenticate(login_params["password"])
                user
            else
                nil
            end
        else
            return nil
        end
    end

end