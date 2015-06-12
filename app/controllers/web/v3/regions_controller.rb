class Web::V3::RegionsController < MetalCorsController

    before_action :authenticate_general

    def index

        success CITY_LIST
        respond
    end

    def merchants
        providers = Provider.where(city_id: params[:id])
        success providers.serialize_objs(:web)
        respond
    end

end
