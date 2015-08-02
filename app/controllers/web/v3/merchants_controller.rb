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
        merchant = Merchant.find(params[:id])
        menu = Menu.find(merchant.menu_id)
        success({ "menu" => menu, "loc_id" => merchant.id })
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

end
