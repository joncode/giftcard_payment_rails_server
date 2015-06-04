class Mdot::V2::CitiesController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def index
        @app_response = CITY_LIST
        success @app_response
        respond
    end

    def merchants
        if params[:id].to_i == 0
            region_id = region_id_from_name params[:id]
        else
            region_id = params[:id].to_i
        end
        providers = Provider.where(region_id: region_id)
        @app_response = providers.serialize_objs
        success @app_response
        respond
    end

private

    def region_id_from_name name
        region_hash = CITY_LIST.select { |region_h| region_h["name"] == name }
        region_hash[0]["region_id"].to_i
    end

    def city_name_from_id id_int
        city_name = nil
        CITY_LIST.each do |city|
            if city["region_id"] == id_int
                city_name = city["name"]
                break
            end
        end
        return city_name
    end

end
