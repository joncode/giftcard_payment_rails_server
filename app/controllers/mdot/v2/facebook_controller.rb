class Mdot::V2::FacebookController < JsonController

    before_action :authenticate_customer
    before_action :get_current_user_fb_oauth, except: :oauth
    rescue_from JSON::ParserError, :with => :bad_request

    def friends
        sproxy = SocialProxy.new(@user_oauth.to_proxy)
        sproxy.friends

        if sproxy.status == 200
            if sproxy.data.count > 0
                BulkContact.upload(data: sproxy.data, user_id: @current_user.id)
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
        oauth_hsh["network"] = "facebook"
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
        params.require(:data).permit(:token, :network_id, :photo)
    end
end




