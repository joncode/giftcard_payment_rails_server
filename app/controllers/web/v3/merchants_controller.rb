class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index
        # binding.pry
        arg_scope = proc { Provider.all }
        merchants = @current_client.contents(:merchants, &arg_scope)
        if !merchants.nil? && merchants.count > 0
            providers = merchants
            if providers[0].class == Merchant
                providers = providers.map(&:provider)
            end
        else
            providers = []
        end
        success providers.serialize_objs(:web)
        respond
    end

    def menu
        menu        = MenuString.get_menu_v2_for_provider(params[:id])
        menu_string = MenuString.find_by(provider_id: params[:id])
        success({ "menu" => menu_string.menu_json, "loc_id" => menu_string.provider_id })
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

end
