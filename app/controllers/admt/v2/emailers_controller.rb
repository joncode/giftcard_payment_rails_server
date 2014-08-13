class Admt::V2::EmailersController < JsonController
    include Emailer
    before_action :authenticate_admin_tools

    def call_notify_receiver_proto_join
        response = notify_receiver_proto_join(params[:data])
        if response[0]["status"] == "sent"
            success "Email sent for gift #{params[:data][:gift_id]}"
        else
            fail "Unable to send email. Please Retry"
        end
        respond 
    end

end
