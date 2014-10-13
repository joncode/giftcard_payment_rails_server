class Web::V3::RegionsController < MetalCorsController

    before_action :authenticate_general

    def index
        city_list = CITY_LIST
        city_list.each  do |c|
            c["token"]     = c["name"].downcase.gsub(' ', '-')
            c["region_id"] = c["city_id"]
        end
        success city_list
        respond
    end

    def merchants
        providers = Provider.where(region_id: params[:id])
        success providers.serialize_objs(:web)
        respond
    end

end
