class Mdot::V2::SettingsController < JsonController
    before_action :authenticate_customer

    rescue_from JSON::ParserError, :with => :bad_request



    def index
        settings  = @current_user.get_settings
        if settings
            success settings
        else
            fail    data_not_found
            status = :not_found
        end

        respond(status)
    end

    def update
        params["data"] = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        return nil  if data_not_hash?(params["data"])
        # settings_params = strong_param(data)
        return nil  if hash_empty?(params["data"])

        if @current_user.save_settings(settings_params)
            success @current_user.setting.app_serialize
        else
            fail @current_user.setting
            status = :bad_request
        end

        respond(status)
    end

private

    def settings_params
        params.require(:data).permit(:email_receiver_new, :email_invite, :email_redeem, :email_invoice, :email_follow_up, :email_reminder_gift_receiver, :email_reminder_gift_giver)
    end

    # def strong_param data_hsh
    #     allowed = ["email_receiver_new", "email_invite", "email_redeem", "email_invoice", "email_follow_up", "email_reminder_gift_receiver", "email_reminder_gift_giver"]
    #     data_hsh.select{ |k,v| allowed.include? k }
    # end

end