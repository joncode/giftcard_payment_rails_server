class Web::V3::RegionsController < MetalController

    def index
        success CITY_LIST_WEB
        respond
    end

    def merchants
        providers = Provider.where(region_id: params[:id])
        success providers.serialize_objs(:web)
        respond
    end

end
