class Web::V3::MerchantsController < MetalController

    before_action :authenticate_web_general

    def index
        providers = Provider.all
        success providers.serialize_objs(:web)
        respond
    end

    def menu
        menu        = MenuString.get_menu_v2_for_provider(params[:id])
        menu_string = MenuString.find_by(provider_id: params[:id])
        success({ "menu" => menu_string.menu_json, "loc_id" => menu_string.provider_id })
        respond
    end

end
