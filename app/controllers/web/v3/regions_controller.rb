class Web::V3::RegionsController < MetalController

    before_action :authenticate_web_general

    def index
        city_list_web = CITY_LIST.each do |city|
            city["token"] = city["name"].downcase.gsub(/ /, '_')
            city["region_id"] = city.delete("city_id")
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
