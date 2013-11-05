class Mdot::V2::ProvidersController < JsonController
    before_filter :authenticate_customer

    def show
        respond
    end

    def menu
        respond
    end

end