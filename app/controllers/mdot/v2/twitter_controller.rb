class Mdot::V2::TwitterController < JsonController

    before_action :authenticate_customer
    before_action :get_current_user_tw_oauth, except: :oauth

    def friends

        sproxy = SocialProxy.new(@user_oauth.to_proxy)
        sproxy.friends

        if sproxy.status == 200
            if sproxy.data.count > 0
                AppContact.upload(proxy_contacts: sproxy.data, user: @current_user)
            end
            success sproxy.data
            respond(status)
        else
            fail    sproxy.data.to_s
            @app_response["msg"] = sproxy.msg
            status = sproxy.status
            respond(status)
        end

    end

    def profile
        sproxy = SocialProxy.new(@user_oauth.to_proxy)
        sproxy.profile

        if sproxy.status == 200
            success sproxy.data
            respond(status)
        else
            fail    sproxy.data.to_s
            @app_response["msg"] = sproxy.msg
            status = sproxy.status
            respond(status)
        end
    end

    def create
        sproxy = SocialProxy.new(@user_oauth.to_proxy)
        sproxy.create_post params["data"]

        if sproxy.status == 200
            success sproxy.data
            respond(status)
        else
            fail    sproxy.data.to_s
            @app_response["msg"] = sproxy.msg
            status = sproxy.status
            respond(status)
        end
    end

    def oauth
        oauth_hsh = oauth_params
        oauth_hsh["network"] = "twitter"
        oauth_hsh["user_id"] = @current_user.id
        oauth = Oauth.create(oauth_hsh)

        if oauth.id.present?
            success oauth.id.to_s
        else
            fail    oauth
            status = :bad_request
        end
        respond(status)
    end

private

    def oauth_params
        params.require(:data).permit(:token, :network_id, :secret, :handle, :photo)
    end
end





