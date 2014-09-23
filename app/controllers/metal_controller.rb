class MetalController < ActionController::Base

    include CommonUtils

    skip_before_action   :verify_authenticity_token
    before_action        :log_request_header
    before_action        :method_start_log_message
    after_action         :method_end_log_message

    def not_found
        head 404
    end

    def bad_request
        head 400
    end

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

    def fail_web payload
        data_array = []
        if payload[:data].present?
            payload[:data].each do |k, v|
                data_array << { name: k, msg: v }
            end
        end
        @app_response = {
            status: 0,
            err:    payload[:err],
            msg:    payload[:msg],
            data:   data_array
        }
    end

    def fail_web_payload error_name, error_data=nil
        case error_name
        when "invalid_email"
            {
                err: "INVALID_INPUT",
                msg: "We don't recognize that email and password combination"
            }
        when "invalid_facebook"
            {
                err: "INVALID_INPUT",
                msg: "We don't recognize that facebook account"
            }
        when "invalid_twitter"
            {
                err: "INVALID_INPUT",
                msg: "We don't recognize that twitter account"
            }
        when "suspended_user"
            {
                err: "INACTIVE_USER",
                msg: "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
            }
        when "not_created_user"
            {
                err: "INVALID_INPUT",
                msg: "User could not be created",
                data: error_data
            }
        when "not_created_gift"
            {
                err: "INVALID_INPUT",
                msg: "Gift could not be created",
                data: error_data
            }
        when "incomplete_info"
            {
                err: "INCOMPLETE_INPUT",
                msg: "Missing Card Data"
            }
        end
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

end
