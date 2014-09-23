class MetalCorsController < MetalController

	before_action :print_params
    after_filter  :cross_origin_allow_header
    #after_action  :print_params


protected

    def authenticate_user
        if token = request.headers["HTTP_X_AUTH_TOKEN"]
            @current_user = User.app_authenticate(token)
            if @current_user
                puts "Web  -------------   #{@current_user.name}   -----------------------"
            else
                head :unauthorized
            end
        else
            head :unauthorized
        end
    end

    def authenticate_general
        puts "#{request.headers.inspect}"
        if token    = request.headers["HTTP_X_AUTH_TOKEN"]
            puts "\n\n Auth token == #{token}\n\n"
            if (WWW_TOKEN == token)
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

	def print_params
		puts "-------- mccontroller request #{request.headers.inspect}"
	end

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin']   = "*"
        headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, HTTP_X_AUTH_TOKEN, X_AUTH_TOKEN, http_x_auth_token, x_auth_token, Mdot-Version, Android-Version'
    end

end
