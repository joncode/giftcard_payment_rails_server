class Mdot::V2::FacebookController < JsonController

    before_action :authenticate_customer,      only: [:index, :update, :show, :deactivate_user_social]

    def index
        success ["got em"]
        respond(status)
    end

end