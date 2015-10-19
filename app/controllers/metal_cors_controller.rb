class MetalCorsController < MetalController

	# before_action :print_params
    after_action :cross_origin_allow_header



protected

    def authentication_no_token
        successful = authenticate_client
        successful = authenticate_general if successful
        attach_token_to_user if successful
    end

    def authentication_token_required
        successful = authenticate_client
        successful = authenticate_user  if successful
        confirm_client_owns_token if successful
    end

    def confirm_client_owns_token
        sto = @current_user.session_token_obj
        unless sto.client_id == @current_client.id && sto.partner_id == @current_partner.id && sto.partner_type == @current_partner.class.to_s
            puts "----  DENIED SESSION TOKEN NOT CLIENT TOKEN ---- (500 Internal)"
            head :unauthorized
        end

    end

    def attach_token_to_user
        if token = request.headers["HTTP_X_AUTH_TOKEN"]
            if (![REDBULL_TOKEN, WWW_TOKEN].include?(token))
                @current_user = SessionToken.app_authenticate(token)
            end
        end
    end

    def authenticate_client
        @current_client = nil
        @current_partner = nil
        # puts "\n HTTP_X_APPLICATION_KEY = #{request.headers['HTTP_X_APPLICATION_KEY']}"
        # puts request.headers.inspect
        app_key = request.headers['HTTP_X_APPLICATION_KEY']
        if !app_key.blank?
            # binding.pry
            if @current_client = Client.includes(:partner).find_by(application_key: app_key)
                @current_partner = @current_client.partner
            end
        else
            @current_partner = Affiliate.find(28)
            hsh = {name: "Web Gifting Menu", url_name: "gift_menu", download_url: "www.itson.me/gift_menu", detail: "Its On Me Web Gifting Menu Portal"}
            @current_client = Client.new(hsh)
            @current_client.partner_id = 28
            @current_client.partner_type = 'Affiliate'
            @current_client.platform = :web_menu
        end

        if @current_client && @current_partner
            puts "Web  -------------   #{@current_client.name} | #{@current_partner.name}  -------------"
            return true
        else
            head :unauthorized
            return false
        end
    end

    def authenticate_user
        if token = request.headers["HTTP_X_AUTH_TOKEN"]
            @current_user = SessionToken.app_authenticate(token)
            if @current_user
                puts "Web  -------------   #{@current_user.name}   -----------------------"
                return true
            else
                head :unauthorized
                return false
            end
        else
            head :unauthorized
            return false
        end
    end

    def authenticate_general
        #puts "\n\n\n#{request.headers.inspect}"
        if token    = request.headers["HTTP_X_AUTH_TOKEN"]
            if ([REDBULL_TOKEN, WWW_TOKEN].include?(token))
                puts "Web  -------------    General Token   -----------------------"
            else
                @current_user = User.app_authenticate(token)
                if @current_user
                    puts "Web  -------------   #{ @current_user.name }   -----------------------"
                else
                    head :unauthorized
                end
            end
        else
            head :unauthorized
        end
    end

private

	# def print_params
	# 	puts "-------- mccontroller request #{request.headers.inspect}"
	# end

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin']   = "*"
        headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers']  = 'Origin, Cache-Control, Accept-Encoding, Connection, Content-Length, Cookie, Host, User-Agent, Accept-Language, Referer, cache-control, accept, content-type, X-Requested-With, Content-Type, Accept, x-auth_token, X-AUTH_TOKEN, x-auth-token, X-AUTH-TOKEN, X_AUTH_TOKEN, x_auth_token'
    end

end
