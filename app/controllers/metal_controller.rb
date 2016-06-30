class MetalController < ActionController::Base
    include ActionView::Helpers::NumberHelper
    include CommonUtils

    skip_before_action   :verify_authenticity_token
    before_action        :log_request_header
    before_action        :method_start_log_message
    after_action         :method_end_log_message

    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActiveModel::ForbiddenAttributesError, :with => :bad_request

    def not_found
        head 404
    end

    def bad_request
        head 400
    end

    def data_not_string?(data=nil)
        data ||= params["data"]
        head :bad_request unless data.kind_of?(String)
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

    def make_data_ary payload_msgs
        data_array = []
        payload_msgs.each do |k, v|

            v = v.join(',') if v.kind_of?(Array)

            if k == :identifier
                k = v.match(/\A\w+\b/)[0]
            end

            data_array << { name: k.to_s.humanize.downcase, msg: v }
        end
        return data_array
    end

    def fail_web payload
        data_array = []

        # binding.pry

        if payload[:data].present? && !payload[:data].kind_of?(Hash) && !payload[:data].kind_of?(String) && !payload[:data].kind_of?(Array)

            if payload[:data].respond_to?(:messages)
                data_array = make_data_ary(payload[:data].messages)
            else
                data_array = make_data_ary(payload[:data].errors.messages)
            end

        elsif payload[:data].present? && !payload[:data].kind_of?(String)
            data_array = make_data_ary(payload[:data])
        else
            if payload[:data].present?
                data_array << { msg: payload[:data] }
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
        when "not_created_card"
            puts  "\nHere is ERROR DATA " + error_data.inspect
            if error_data.kind_of?(Array) && error_data[0][:msg].present?
                error_data = [{ msg: error_data[0][:msg]}]
            end
            {
                err: "INVALID_INPUT",
                msg: "We are unable to process credit card.",
                data: error_data
            }

        when "incomplete_info"
            {
                err: "INCOMPLETE_INPUT",
                msg: "Missing Card Data"
            }
        when "client_deactivated"
            {
                err: "CLIENT_DEACTIVTED",
                msg: "Client is not currently active"
            }
        when "unable_to_attach_facebook"
            {
                err: "UNABLE_TO_ATTACH_FACEBOOK_PROFILE",
                msg: "Unable to attach Facebook Profile",
                data: error_data
            }
        else
            if error_name.kind_of?(String)
                if error_data
                    {
                        err: error_name.gsub(' ', '_').upcase,
                        msg: error_data
                    }
                else
                    {
                        err: error_name.gsub(' ', '_').upcase,
                        msg: error_name
                    }
                end
            end
        end
    end


protected

    def authenticate_user
        token         = request.headers["HTTP_X_AUTH_TOKEN"]
        @current_user = User.app_authenticate(token)
        if @current_user
            puts "APP  -------------   #{@current_user.name} #{@current_user.id}  -----------------------"
        else
            head :unauthorized
        end
    end

end
