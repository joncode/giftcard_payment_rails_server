class Mdot::V2::BrandsController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        success(Brand.all.serialize_objs)
        respond
    end

    def merchants
        brand = Brand.find(params[:id])
        success(brand.merchants.serialize_objs)
        respond
    end

end