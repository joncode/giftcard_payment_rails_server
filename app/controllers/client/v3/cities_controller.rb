class Client::V3::CitiesController < MetalController



    def index
        success CITY_LIST
        respond
    end

    def merchants
        providers = Provider.where(region_id: params[:id])
        success providers.serialize_objs
        respond
    end





















end