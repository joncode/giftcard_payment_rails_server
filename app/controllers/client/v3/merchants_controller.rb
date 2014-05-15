class Client::V3::MerchantsController < JsonController


    def show
        menu = MenuString.get_menu_v2_for_provider(params[:id])
        success({ "provider_id" => params[:id].to_i, "menu" => menu })
        respond
    end





















end