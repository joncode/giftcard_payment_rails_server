class Web::V3::RegionsController < MetalCorsController

    before_action :authentication_no_token

    def index
        # binding.pry
        cache_resp = RedisWrap.get_cities(@current_client.id)
        if !cache_resp
            arg_scope = proc { Region.city.order(position: :asc) }
            cities_serialized = @current_client.contents(:regions, &arg_scope).map(&:old_city_json)
            RedisWrap.set_cities(@current_client.id, cities_serialized)
            success cities_serialized
        else
            success cache_resp
        end
        respond
    end

    def merchants
        region_id = params[:id].to_i
        cache_resp = RedisWrap.get_region_merchants(@current_client.id, region_id)
        if !cache_resp
            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
            merchants = @current_client.contents(:merchants, &arg_scope)
            if !merchants.nil? && merchants.count > 0
                merchants_in_city = merchants.select{ |m| m.city_id == region_id }
                cities_serialized = merchants_in_city.serialize_objs(:web)
                RedisWrap.set_region_merchants(@current_client.id, region_id, cities_serialized)
                success cities_serialized
            else
                status = :not_found
                fail_web({ err: "NOT_FOUND", msg: 'No merchants found'})
            end
        else
            success cache_resp
        end
        respond
    end

end
