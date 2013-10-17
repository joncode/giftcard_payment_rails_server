class Admt::V2::BrandsController < JsonController


    def create
        puts "HERE IS THE PARAMS data = #{params["data"].inspect}"
        brand_hsh = params["data"]
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
        brand = Brand.unscoped.find(params["data"]["brand_id"].to_i)
        if brand && brand.update_attributes(params["data"]["brand"])
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
