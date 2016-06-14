class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def signup
        submit_obj = MerchantSignup.new(merchant_signup_params)

        if submit_obj.save
            mail_notice_submit_merchant_setup(submit_obj)
            mail_merchant_signup_welcome(submit_obj)
            success
        else
            fail_web({
                err: "INVALID_INPUT",
                msg: submit_obj.errors.full_messages
            })
        end

        respond
    end

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

        if merchant.menu_id.nil?
            cache_resp = []
        else
            cache_resp = RedisWrap.get_menu(merchant.menu_id)
            if !cache_resp || (cache_resp == [])
                cache_resp = merchant.menu_string
                RedisWrap.set_menu(merchant.menu_id, cache_resp)
            end
        end

        success({ "menu" => cache_resp, "loc_id" => merchant.id })
        respond
    end

    def redeem_locations
        merchant = Merchant.unscoped.find(params[:id])
        if client = merchant.client
            serialized = client.contents(:merchants).map(&:web_serialize)
        else
            serialized = [ merchant ].map(&:web_serialize)
        end
        success(serialized)
        respond
    end

    def receipt_photo_url
        success({ "receipt_photo_url" => DEFAULT_RECEIPT_IMG_URL})
        respond
    end

private

    def mail_notice_submit_merchant_setup merchant_submit_obj
        data = { 'method' => 'mail_notice_submit_merchant_setup', 'args' => merchant_submit_obj }
        Resque.enqueue(InternalMailerJob, data)
    end

    def mail_merchant_signup_welcome merchant_submit_obj
        data = { 'text' => 'merchant_signup_welcome', 'args' => merchant_submit_obj }
        Resque.enqueue(MailerJob, data)
    end

    def merchant_signup_params
        params.require(:merchant_signup).permit('address', "venue_name", "venue_url",
             "point_of_sale_system", "name", "email", "phone", "position", "message")
    end

end
