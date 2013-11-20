class Mdot::V2::SettingsController < JsonController
    before_filter :authenticate_customer

    rescue_from JSON::ParserError, :with => :bad_request

    def index
        settings  = @current_user.get_settings
        if settings
            success settings
        else
            fail    data_not_found
        end
        respond
    end

    def update
        data = if params["data"].kind_of?(String)
            JSON.parse(params["data"])
        else
            params["data"]
        end

        return nil  if data_not_hash?(data)
        settings_params = strong_param(data)
        return nil  if hash_empty?(settings_params)

        if @current_user.save_settings(settings_params)
            setting = @current_user.setting
            success setting.serialize
        else
            fail @current_user.setting
        end
        respond
    end

private

    def strong_param data_hsh
        allowed = ["email_receiver_new","email_invite","email_redeem","email_invoice","email_follow_up"]
        data_hsh.select{ |k,v| allowed.include? k }
    end

end