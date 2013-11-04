class Mdot::V2::BrandsController < JsonController
    before_filter :authenticate_customer

    def index
        respond
    end

end