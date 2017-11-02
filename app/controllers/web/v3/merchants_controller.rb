class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token


    # {"data"=>{"stripe_id"=>"tok_1BElUpHMscfhJNOLBh9", "name"=>"FULL NAME", "email"=>"EMAIL@EXAMPLE.me", "merchant_name"=>"ItsoNme",
    #       "zip"=>"89101", "last_four"=>"4242", "brand"=>"Visa", "csv"=>"[FILTERED]", "month"=>"04", "year"=>"27", "term"=>"Year", "amount"=>30000}}
    def card
        create_with = anon_stripe_card_params
        create_with['client_id'] = @current_client.id
        create_with['partner_id'] = @current_partner.id
        create_with['partner_type'] = @current_partner.class.to_s
        card = CardStripe.create_card_from_hash create_with
        card.save
        if card.active && card.persisted?
            success 'Card Created'
        else
            fail_web fail_web_payload("not_created_card", card.error_message)
            # status = :bad_request
        end
        respond(status)
    end

    def signup
        extra_data = params[:data].delete(:data)
        hsh = merchant_signup_params
        extra_data['client_id'] = @current_client.try(:id)
        extra_data['partner_id'] = @current_partner.try(:id)
        extra_data['partner_type'] = @current_partner.class.to_s
        hsh[:data] = extra_data
        submit_obj = MerchantSignup.new(hsh)

        if submit_obj.save
            success submit_obj
        else
            fail_web({
                err: "INVALID_INPUT",
                msg: submit_obj.errors.full_messages
            })
        end
        respond
    end

    def supply_request
        extra_data = params[:data].delete(:form_data)
        hsh = merchant_signup_params
        extra_data['client_id'] = @current_client.try(:id)
        extra_data['partner_id'] = @current_partner.try(:id)
        extra_data['partner_type'] = @current_partner.class.to_s
        hsh[:data] = extra_data
        supply_order = SupplyOrder.new(hsh)

        if supply_order.save
            success supply_order
        else
            fail_web({
                err: "INVALID_INPUT",
                msg: supply_order.errors.full_messages
            })
        end
        respond
    end

    def show
        merchant = Merchant.unscoped.find(params[:id])
        if merchant.menu_id.nil?
            cache_resp = []
        else
            cache_resp = RedisWrap.get_menu(merchant.menu_id)
            if !cache_resp || (cache_resp == [])
                cache_resp = merchant.menu_string
                RedisWrap.set_menu(merchant.menu_id, cache_resp)
            end
        end
        success({ "menu" => cache_resp, "loc_id" => merchant.id, "merchant" => merchant.web_serialize })
        respond
    end

    def books
        merchant = Merchant.unscoped.find(params[:id])
        success({ "books" => merchant.books.map(&:list_serialize), "loc_id" => merchant.id })
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
        merchant = Merchant.unscoped.find(params[:id])

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

    def anon_stripe_card_params
        params.require(:data).permit(:term, :amount, :merchant_name, :email, :stripe_user_id, :stripe_id, :name, :zip, :last_four, :brand, :csv, :month, :year)
    end

    def merchant_signup_params
        # properties_keys = params[:data].try(:fetch, 'data', {}).keys.map(&:to_sym)
        params.require(:data).permit(:address, :venue_name, :venue_url,
             :point_of_sale_system, :name, :email, :phone, :position, :message )

        # params.require(:data).permit(:address, :venue_name, :venue_url,
        #      :point_of_sale_system, :name, :email, :phone, :position, :message, :data).tap do |whitelisted|
        #     whitelisted[:data] = params[:data][:data]
        # end
    end

end
