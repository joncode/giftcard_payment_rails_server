class Mdot::V2::ProvidersController < JsonController

    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request


    def menu
        merchant = Merchant.find(params[:id])
        menu = Menu.find(merchant.menu_id)
        menu_string = JSON.parse(menu.json)
        if menu
            success({ "provider_id" => params[:id].to_i, "menu" => menu_string })
        else
            not_found
            return nil
        end
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end
end