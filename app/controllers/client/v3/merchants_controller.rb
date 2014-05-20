class Client::V3::MerchantsController < MetalController

    def show
        menu = MenuString.get_menu_v2_for_provider(params[:id])
        provider = Provider.find(params[:id])
        success(provider.client_serialize)
        respond
    end






















end