class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index

        cache_resp = RedisWrap.get_merchants(@current_client.id)
        if !cache_resp || (cache_resp == [])
            arg_scope = proc { Merchant.where(active: true).where(paused: false).order("name ASC") }
            merchants = @current_client.contents(:merchants, &arg_scope)
            cache_resp = merchants.serialize_objs(:web)
            RedisWrap.set_merchants(@current_client.id, cache_resp)
        end

        success cache_resp
        respond
    end

    def menu
        merchant = Merchant.unscoped.find(params[:id].to_i)

        cache_resp = RedisWrap.get_menu(merchant.menu_id)
        if !cache_resp || (cache_resp == [])
            cache_resp = merchant.menu_string
            RedisWrap.set_menu(merchant.menu_id, cache_resp)
        end

        success({ "menu" => cache_resp, "loc_id" => merchant.id })
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
