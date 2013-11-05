class Mdot::V2::SettingsController < JsonController
    before_filter :authenticate_customer

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
        respond
    end

end