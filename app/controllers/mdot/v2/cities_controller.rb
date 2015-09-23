class Mdot::V2::CitiesController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        @app_response = Region.city.map(&:old_city_json)
        success @app_response
        respond
    end

    def merchants
        if params[:id].to_i == 0
            region_id = region_id_from_name params[:id]
        else
            region_id = params[:id].to_i
        end

        merchants = Merchant.where(active: true, paused: false, city_id: region_id).order("name ASC")
        @app_response = merchants.serialize_objs
        success @app_response
        respond
    end

private

    def region_id_from_name name

        region_hash = Region.city.map(&:old_city_json).select { |region_h| region_h["name"] == name }
        region_hash[0]["region_id"].to_i
    end

    def city_name_from_id id_int
        city_name = nil
        Region.city.map(&:old_city_json).each do |city|
            if city["region_id"] == id_int
                city_name = city["name"]
                break
            end
        end
        return city_name
    end

end
