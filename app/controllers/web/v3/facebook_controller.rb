class Web::V3::FacebookController < MetalCorsController
    include ERB::Util

    # before_action :authentication_no_token
    # before_action :get_current_user_fb_oauth, except: :oauth
    before_action :authentication_token_required, except: [:oauth_init, :callback_url]
    rescue_from JSON::ParserError, :with => :bad_request


    def friends
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.friends

        # if sproxy.status == 200
        #     if sproxy.data.count > 0
        #         BulkContact.upload(data: sproxy.data, user_id: @current_user.id)
        #     end
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end

    end

    def profile
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.profile

        # if sproxy.status == 200
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end
    end

    def create
        # sproxy = SocialProxy.new(@user_oauth.to_proxy)
        # sproxy.create_post params["data"]

        # if sproxy.status == 200
        #     success sproxy.data
        #     respond(status)
        # else
        #     fail    sproxy.data.to_s
        #     @app_response["msg"] = sproxy.msg
        #     status = sproxy.status
        #     respond(status)
        # end
    end

    def oauth_init
        return_url = params['return_url'] || 'https://www.itson.me'
        return_url = url_encode(return_url)
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, API_URL + '/facebook/callback_url?return_url=' + return_url)
        redirect_url = oauth.url_for_oauth_code(scope: ['public_profile', 'user_friends', 'email'])
        # success redirect_url
        # respond(:found)
        redirect_to redirect_url
    end

    def callback_url
        puts params.inspect
        return_url = params['return_url'] || 'https://www.itson.me'
        return_url = url_encode(return_url)
        oauth = Koala::Facebook::OAuth.new(FACEBOOK_APP_ID, FACEBOOK_APP_SECRET, API_URL + '/facebook/callback_url?return_url=' + return_url)
        oauth_access_token = oauth.get_access_token(params['code'])
        graph = Koala::Facebook::API.new(oauth_access_token)
        profile = graph.get_object("me")
        puts profile.inspect
        puts "\n\n #{return_url}\n\n"
        if profile['id'].present?
            user_social = UserSocial.includes(:user).where(type_of: 'facebook_id', identifier: profile['id']).first
            @user       = user_social ? user_social.user : nil
            # success @user.login_client_serialize
            redirect_to URI.decode(return_url)
        else
            # fail profile
            redirect_to URI.decode(return_url)
        end
        # respond
    end

    def oauth
        oauth_hsh = oauth_params
        oauth_hsh["network"] = "facebook"
        oauth_hsh["user_id"] = @current_user.id
        save_user = false

        if oauth_hsh['sex'].present? && @current_user.sex.nil?
            @current_user.sex = oauth_hsh['sex']
            save_user = true
        end
        oauth_hsh.delete('sex')

        if oauth_hsh['birthday'].present? && @current_user.birthday.nil?
            puts oauth_hsh['birthday'].inspect
            @current_user.birthday = oauth_hsh['birthday']
            save_user = true
        end
        oauth_hsh.delete('birthday')

        oauth = Oauth.create(oauth_hsh)
        if oauth.persisted?

            if @current_user.facebook_id != oauth.network_id
                @current_user.facebook_id = oauth.network_id
                save_user = true
            end

            if oauth_hsh["photo"].present? && @current_user.get_photo == BLANK_AVATAR_URL
                @current_user.iphone_photo = oauth_hsh["photo"]
                save_user = true
            end

            if save_user
                if @current_user.save
                    success @current_user.login_client_serialize
                else
                    fail_web    fail_web_payload("not_created_user", @current_user.errors.messages)
                end
            else
                success @current_user.login_client_serialize
            end
        else
            fail_web    fail_web_payload("invalid_facebook", oauth.errors.messages)
            status = :bad_request
        end
        respond(status)
    end

private

    def oauth_params
        params.require(:data).permit(:token, :net_id, :photo, :sex, :birthday)
    end
end




