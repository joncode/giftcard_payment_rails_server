class MetalController < ActionController::Base

    include CommonUtils

    before_action        :log_request_header
    before_action        :method_start_log_message
    after_action         :method_end_log_message

    def respond(status=nil)
        response_code = status || :ok
        respond_to do |format|
            format.json { render json: @app_response, status: response_code }
        end
    end

    def success payload
        @app_response = { status: 1, data: payload }
    end

    def fail payload
        unless payload.kind_of?(Hash) || payload.kind_of?(String) || payload.kind_of?(Array)
            payload   = { "error" => payload.errors.messages }
        end
        @app_response = { status: 0, data: payload }
    end

    def fail_web fail_hash
        data_array = []
        if fail_hash[:errors_hash].present?
            fail_hash[:errors_hash].each do |k, v|
                data_array << { name: k, msg: v }
            end
        end
        @app_response = {
            status: 0,
            err:    fail_hash[:error_type],
            msg:    fail_hash[:error_description],
            data:   data_array
        }
    end

protected

    def authenticate_user
        token         = request.headers["HTTP_X_AUTH_TOKEN"]
        @current_user = User.app_authenticate(token)
        if @current_user
            puts "APP  -------------   #{@current_user.name}   -----------------------"
        else
            head :unauthorized
        end
    end

    def authenticate_web_user
        token         = request.headers["TKN"]
        @current_user = User.app_authenticate(token)
        if @current_user
            puts "Web  -------------   #{@current_user.name}   -----------------------"
        else
            head :unauthorized
        end
    end

    def authenticate_web_general
        token    = request.headers["TKN"]
        @current_user = User.app_authenticate(token)
        if (WWW_TOKEN == token) || @current_user
            puts "Web  -------------   #{@current_user ? @current_user.name : "General Token"}   -----------------------"
        else
            head :unauthorized
        end
    end

end