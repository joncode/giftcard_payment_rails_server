class Mdot::V2::CitiesController < JsonController
    before_filter :authenticate_customer
    
    def index
        respond
    end

end