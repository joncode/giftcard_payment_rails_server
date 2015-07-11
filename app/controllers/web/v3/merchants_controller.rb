class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index
        # binding.pry
        arg_scope = proc { Merchant.all }
        merchants = @current_client.contents(:merchants, &arg_scope)

        success merchants.serialize_objs(:web)
        respond
    end

    def menu
        menu        = MenuString.get_menu_v2_for_provider(params[:id])
        menu_string = MenuString.find_by(merchant_id: params[:id])
        success({ "menu" => menu_string.menu_json, "loc_id" => menu_string.merchant_id })
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

end
