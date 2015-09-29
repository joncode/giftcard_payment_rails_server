class Web::V3::TwitterController < MetalCorsController

    # before_action :authenticate_customer
    # before_action :get_current_user_tw_oauth, except: :oauth
    before_action :authentication_token_required
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

    def oauth
        oauth_hsh = oauth_params
        oauth_hsh["network"] = "twitter"
        oauth_hsh["user_id"] = @current_user.id
        oauth = Oauth.create(oauth_hsh)

        if oauth.persisted?
            save_user = false

            if @current_user.twitter != oauth.network_id
                @current_user.twitter = oauth.network_id
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
            fail_web    fail_web_payload("invalid_twitter", oauth.errors.messages)
            status = :bad_request
        end
        respond(status)
    end

private

    def oauth_params
        params.require(:data).permit(:token, :net_id, :secret, :handle, :photo)
    end
end





