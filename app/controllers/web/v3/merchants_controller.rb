class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index
        cache_resp = RedisWrap.get_merchants(@current_client.id)
        if !cache_resp
            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
            merchants = @current_client.contents(:merchants, &arg_scope)
            merchants_serialized = merchants.serialize_objs(:web)
            RedisWrap.set_merchants(@current_client.id, merchants_serialized)
            success merchants_serialized
        else
            success cache_resp
        end
        respond
    end

    def menu
        merchant = Merchant.unscoped.find(params[:id])
        success({ "menu" =>  merchant.menu_string, "loc_id" => merchant.id })
        respond
    end

    def redeem_locations
        merchant = Merchant.unscoped.find(params[:id])
        if client = merchant.client
            redeems = client.contents(:merchants)
            serialized = redeems.map(&:web_serialize)
            success(serialized)
        else
            success([ merchant.web_serialize ])
        end
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

end
