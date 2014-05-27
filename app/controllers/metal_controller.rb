class MetalController < ActionController::Base
    # include ActionController::Helpers
    # include ActionController::Redirecting
    # include ActionController::Rendering
    # include ActionController::Renderers::All
    # include ActionController::ConditionalGet

    # include ActionController::MimeResponds
    # # include ActionController::RequestForgeryProtection
    # include ActionController::ForceSSL
    # include AbstractController::Callbacks
    # include ActionController::Instrumentation

    # include Rails.application.routes.url_helpers
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
end