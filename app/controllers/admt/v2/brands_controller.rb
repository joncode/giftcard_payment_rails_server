class Admt::V2::BrandsController < JsonController

    before_action :authenticate_admin_tools
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        brand_hsh = params["data"]
        puts brand_hsh
        brand     = Brand.new brand_params
        if brand.save
            puts    "Here is new brand ID = #{brand.id} = #{brand.inspect}"
            success brand.admt_serialize
        else
            fail    brand
        end
        respond
    end

    def update
        brand = Brand.unscoped.find(params[:id])
        if brand && brand.update_attributes(brand_params)
            success brand.admt_serialize
        else
            if brand
                fail brand
            else
                fail data_not_found
            end
        end
        respond
    end

private

    def brand_params
        params.require(:data).permit(:name, :website, :photo, :description)
    end

end
