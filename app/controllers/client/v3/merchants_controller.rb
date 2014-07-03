class Client::V3::MerchantsController < MetalController

    def show
        provider = Provider.find(params[:id])
        success(provider.client_serialize)
        respond
    end

    def menu
        menu        = MenuString.get_menu_v2_for_provider(params[:id])
        menu_string = MenuString.find_by(provider_id: params[:id])
        success({ "menu" => menu_string.menu_json, "provider_id" => menu_string.provider_id})
        respond
    end

end