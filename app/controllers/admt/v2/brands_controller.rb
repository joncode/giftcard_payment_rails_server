class Admt::V2::BrandsController < JsonController

    before_filter :authenticate_admin_tools

    def create
        brand_hsh = params["data"]
        puts brand_hsh
        brand     = Brand.new brand_hsh
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
        if brand && brand.update_attributes(params["data"])
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

end
