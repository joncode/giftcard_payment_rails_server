class Web::V3::RegionsController < MetalCorsController

    before_action :authenticate_web_general

    def index
        city_list_web = CITY_LIST.map do |city|
            city["token"] = city["name"].downcase.gsub(/ /, '-')
            city["region_id"] = city.delete("city_id")
            city
        end
        success city_list_web
        respond
    end

    def merchants
        providers = Provider.where(region_id: params[:id])
        success providers.serialize_objs(:web)
        respond
    end

end
