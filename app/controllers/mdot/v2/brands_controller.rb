class Mdot::V2::BrandsController < JsonController
    before_filter :authenticate_customer

    def index
        success(Brand.all.serialize_objs)
        respond
    end

    def merchants
        brand = Brand.find(params[:id])
        success(brand.providers.serialize_objs)
        respond
    end

end