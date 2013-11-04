class Mdot::V2::SessionsController < JsonController
    before_filter :authenticate_general_token

    def create
        respond
    end

    def login_social
        respond
    end

end