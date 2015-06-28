class Web::V3::RegionsController < MetalCorsController

    before_action :authentication_no_token

    def index

        success Region.city.map(&:old_city_json)
        respond
    end

    def merchants
        providers = Provider.where(city_id: params[:id])
        success providers.serialize_objs(:web)
        respond
    end

end
