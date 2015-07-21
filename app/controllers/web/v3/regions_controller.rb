class Web::V3::RegionsController < MetalCorsController

    before_action :authentication_no_token

    def index
        # binding.pry
        arg_scope = proc { Region.city }
        success @current_client.contents(:regions, &arg_scope).map(&:old_city_json)
        respond
    end

    def merchants
        # binding.pry
        arg_scope = proc { Merchant.all }
        merchants = @current_client.contents(:merchants, &arg_scope)
        if !merchants.nil? && merchants.count > 0
            merchants_in_city = merchants.select{ |m| m.city_id == params[:id].to_i}
            success merchants_in_city.serialize_objs(:web)
        else
            status = :not_found
            fail_web({ err: "NOT_FOUND", msg: 'No merchants found'})
        end

        respond
    end

end
