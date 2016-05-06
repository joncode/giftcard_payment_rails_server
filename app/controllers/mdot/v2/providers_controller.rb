class Mdot::V2::ProvidersController < JsonController

    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request


    def menu
        merchant = Merchant.find(params[:id])
        if menu = merchant.menu_string
            success({ "provider_id" => params[:id].to_i, "menu" => menu })
        else
            not_found
            return nil
        end
        respond
    end

    def redeem_locations
        merchant = Merchant.unscoped.find(params[:id])
        if client = merchant.client
            serialized = client.contents(:merchants).serialize_objs
        else
            serialized = [ merchant ].serialize_objs
        end
        success(serialized)
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

end