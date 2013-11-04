class Mdot::V2::PhotosController < JsonController
    before_filter :authenticate_customer
    
    def update
        respond
    end

end