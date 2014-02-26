class Mdot::V2::TwitterController < JsonController

    before_action :authenticate_customer
    before_action :get_current_user_tw_oauth

    def friends

        sproxy = SocialProxy.new(@user_oauth.to_proxy)
        sproxy.friends

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

end