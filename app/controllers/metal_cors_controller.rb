class MetalCorsController < MetalController

	# before_action :print_params
    # after_action :cross_origin_allow_header

    PUBLIC_TOKENS = [WWW_TOKEN, GOLFNOW_TOKEN, CLOVER_TOKEN]

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

    def authentication_clover
        puts "\nCLOVER AUTH - #{request.headers["HTTP_X_AUTH_TOKEN"]} - #{request.headers['HTTP_X_APPLICATION_KEY']}\n"
        puts "Here are the header keys #{request.headers.keys}"
        successful = authenticate_general
    end

    def confirm_client_owns_token
        sto = @current_user.session_token_obj
        unless sto.client_id == @current_client.id && sto.partner_id == @current_partner.id && sto.partner_type == @current_partner.class.to_s
            # puts "----  DENIED SESSION TOKEN NOT CLIENT TOKEN ---- (500 Internal)"
            # head :unauthorized
            Resque.enqueue(ClientTokenChangeJob, sto.id, @current_client.id)
        end

    end

    def attach_token_to_user
        if token = request.headers["HTTP_X_AUTH_TOKEN"]
            if (!PUBLIC_TOKENS.include?(token))
                @current_user = SessionToken.app_authenticate(token)
                @current_session = @current_user.session_token_obj if @current_user
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
            if @current_client = Client.includes(:partner).find_by(application_key: app_key, active: true)
                @current_partner = @current_client.partner
            end
        else
            puts "No 'HTTP_X_APPLICATION_KEY' - authenticate_client TRAINING WHEELS"
            if params && params[:controller].to_s == 'clover'
                puts params.inspect

                # head :unauthorized
                # return false

                # make another clover app
                # find the merchant , find the previous clover clients
                # generate a new clover client
                @current_client = Client.find(1)
                @current_partner = @current_client.partner

            else
                @current_client = Client.find(1)
                @current_partner = @current_client.partner
            end
        end

        if @current_client && @current_partner
            @current_client.click
            puts "Web  -------------   #{@current_client.name} #{@current_client.id} | #{@current_partner.name} #{@current_partner.id} -------------"
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
                @current_session = @current_user.session_token_obj
                puts "Web  #{request.original_fullpath} -------------   #{@current_user.name} #{@current_user.id}   -----------------------"

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
        # puts "\n\n\n#{request.headers.inspect}"
        puts "--------------" + params.inspect unless Rails.env.production?
        if token = request.headers["HTTP_X_AUTH_TOKEN"]
            if (PUBLIC_TOKENS.include?(token))
                puts "Web  -------------    General Token   -----------------------"
            else
                @current_user = User.app_authenticate(token)
                if @current_user
                    @current_session = @current_user.session_token_obj
                    puts "Web  -------------   #{ @current_user.name } #{ @current_user.id }   -----------------------"
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
        headers['Access-Control-Allow-Headers']  = 'Origin, Cache-Control, Accept-Encoding, Connection, \
        Content-Length, Cookie, Host, User-Agent, Accept-Language, Referer, cache-control, accept, \
        content-type, X-Requested-With, Content-Type, Accept, \
        x-auth_token, X-AUTH_TOKEN, x-auth-token, X-AUTH-TOKEN, X_AUTH_TOKEN, x_auth_token \
        X_APPLICATION_KEY, X-APPLICATION-KEY, x-application-key, x_application_key, X-APPLICATION_KEY, x-application_key'
    end

end
