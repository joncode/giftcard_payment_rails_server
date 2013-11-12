class Mdot::V2::BrandsController < JsonController
    before_filter :authenticate_customer

    def index
        @app_response = Brand.all.serialize_objs
        success @app_response
        respond
    end

    def merchants
        brand = Brand.find(params[:id])
        @app_response = brand.providers.serialize_objs
        success @app_response
        respond
    end

end