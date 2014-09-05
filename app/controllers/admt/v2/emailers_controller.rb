class Admt::V2::EmailersController < JsonController
    include Emailer
    before_action :authenticate_admin_tools

    def call_emailer
        response = self.send(params[:data][:method], params[:data][:data])
        if response[0]["status"] == "sent"
            success "Email sent for email type: #{ params[:data][:method] }"
        else
            fail "Unable to send email. Please Retry"
        end
        respond 
    end

end
