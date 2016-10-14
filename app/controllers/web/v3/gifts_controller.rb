class Web::V3::GiftsController < MetalCorsController
    include MoneyHelper
    before_action :authentication_token_required, except: [:show, :hex, :detail]

    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

    rescue_from Timeout::Error, :with => :rescue_from_timeout
    rescue_from Rack::Timeout::RequestTimeoutException, :with => :rescue_from_timeout

    def index
        user_id = params[:user_id]
        if user_id && user_id != @current_user.id
            user = User.find(user_id)
        else
            user = @current_user
        end
        cache_resp = RedisWrap.get_user_gifts(@current_client.id, @current_user.id)
        if !cache_resp
            gifts = Gift.get_user_activity_in_client(user, @current_client)
                ##### DO NOT CHANGE THIS -- >  gifts.serialize_objs(:web) !! without changing GiftAfterSaveJob
            _serialized = gifts.serialize_objs(:web)
            RedisWrap.set_user_gifts(@current_client.id, @current_user.id, _serialized)
            success(_serialized)
        else
            success cache_resp
        end
        respond
    end

    def promo
        # promo campaign keyword
        str_code = promo_params[:code]
        if str_code == "pteg" && Rails.env.staging?
            resp = UserAfterCreateEvent.gift_user_for_pt(@current_user, @current_client)
        else
            resp = GiftPromoCode.perform(@current_user, str_code)
        end

        if resp[:status] > 0
            success resp[:data]
        else
            fail_web({ err: "INVALID_INPUT", msg: resp[:data]})
        end
        respond
    end

    def associate
        gift = Gift.includes(:merchant).find_by(hex_id: params[:id])
        raise ActiveRecord::RecordNotFound if gift.nil?

        if gift.receiver_id == @current_user.id
            success gift.serialize
        elsif gift.receiver_id.nil?
            socials = []
            if gift.receiver_email.present?
                socials << UserSocial.new(user_id: @current_user.id, type_of: 'email', identifier: gift.receiver_email)
            end
            if gift.receiver_phone.present?
                socials << UserSocial.new(user_id: @current_user.id, type_of: 'phone', identifier: gift.receiver_phone)
            end
            gift.add_receiver @current_user
            if gift.save
                socials.each do |social|
                    social.save
                end
                Resque.enqueue(GiftOpenedEvent, gift.id)
                success gift.refresh_serialize
            else
                fail_web({ err: "INVALID_INPUT", msg: gift.errors.full_messages })
            end
        else
            fail_web({ err: "INVALID_INPUT", msg: "Gift is associatd with another account." })
        end
        respond
    end

    def hex
        if gift = Gift.includes(:merchant).find_by(hex_id: params[:id])
            success gift.refresh_serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Gift could not be found" })
        end
        respond
    end

    def detail
            # remove the permalink add-number from the id
        id = params[:id].to_i - NUMBER_ID

        if gift = Gift.includes(:merchant).find(id)
            success gift.refresh_serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Gift could not be found" })
        end
        respond
    end

    def show
            # remove the permalink add-number from the id
        id = params[:id].to_i - NUMBER_ID

        if gift = Gift.includes(:merchant).find(id)
            success gift.serialize
        else
            fail_web({ err: "INVALID_INPUT", msg: "Gift could not be found" })
        end
        respond
    end

    def regift
        gift_hsh = {}
        gps = regift_params
        set_receiver(gps, gift_hsh)
        set_origin(gps, gift_hsh)
        gift_hsh["message"] = gps[:msg]
        gift_hsh["scheduled_at"] = gps[:scheduled_at]
        gift_hsh["old_gift_id"] = params[:id]

        gift = GiftRegift.create(gift_hsh)
        if gift.kind_of?(Gift)
            if gift.id.nil?
                fail_web fail_web_payload("not_created_gift", gift.errors)
                if gift.errors.messages == {:receiver=> ["No unique receiver data. Cannot process gift. Please re-log in if this is an error."]}
                    status = :bad_request
                end
            else
                gift.fire_after_save_queue(@current_client)
                success gift.web_serialize
            end
        else
            fail_web({ err: "INVALID_INPUT", msg: "Gift could not be created", data: gift})
            status = :forbidden
        end
        respond(status)
    end

    def create
        gift_hsh = {}
        gps = gift_params
        set_receiver(gps, gift_hsh)
        set_origin(gps, gift_hsh)
        gift_hsh["shoppingCart"]  = gps[:items]
        gift_hsh["giver"]         = @current_user
        gift_hsh["credit_card"]   = gps[:pay_id]

        gift_hsh["merchant_id"]   = gps[:loc_id]
        gift_hsh["value"]         = gps[:value]
        gift_hsh["message"]       = gps[:msg]
        gift_hsh["scheduled_at"]  = gps[:scheduled_at]

        puts "wEB/V3 GIFTS hash #{gift_hsh}"

        gift = GiftSale.create(gift_hsh)
        if gift.kind_of?(Gift) && !gift.id.nil?
            # binding.pry
            gift.fire_after_save_queue(@current_client)
            success gift.web_serialize
        else
            if gift.kind_of?(Gift) && gift.persisted?
                fail_web fail_web_payload("not_created_gift", gift.errors)
            else
                fail_web({ err: "INVALID_INPUT", msg: "Gift could not be created", data: gift})
            end
        end
        respond
    end

    def read
        gift = Gift.includes(:merchant).find params[:id]
        if (gift.receiver_id == @current_user.id)
            if gift.read(@current_client.id)
                gift.fire_after_save_queue(@current_client)
                success gift.web_serialize
            else
                fail_message = if gift.status == 'redeemed'
                        "Gift at #{gift.provider_name} has already been redeemed"
                    else
                        "Gift at #{gift.provider_name} cannot be redeemed"
                    end
                fail_web({ err: "NOT_REDEEMABLE", msg: fail_message})
            end
        else
            fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} cannot be redeemed"})
        end
        respond(status)
    end

    def notify
        gift = Gift.includes(:merchant).find params[:id]
        if (gift.receiver_id == @current_user.id)
            loc_id = redeem_params["loc_id"]
            resp = Redeem.start(gift: gift, loc_id: loc_id, client_id: @current_client.id, api: "web/v3/gifts/#{gift.id}/notify")
            if resp['success']
                gift = resp['gift']
                gift.fire_after_save_queue(@current_client)
                success gift.notify_serialize
            else
                fail_web({ err: "NOT_REDEEMABLE", msg: resp["response_text"]})
            end
        else
            fail_web({ err: "NOT_REDEEMABLE", msg: "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"})
        end
        respond(status)
    end

    def start_redemption
        gift = Gift.includes(:merchant).find params[:id]
        puts "\n IN start_redemption - #{params.inspect}"
        if (gift.receiver_id == @current_user.id)
            loc_id = redeem_params["loc_id"]
            amount = redeem_params["amount"]
            resp = Redeem.start(gift: gift, loc_id: loc_id, amount: amount, client_id: @current_client.id,
                api: "web/v3/gifts/#{gift.id}/start_redemption")
            if resp['success']
                gift = resp['gift']
                gift.fire_after_save_queue(@current_client)
                redemption = resp['redemption'].serialize if resp['redemption'].kind_of?(Redemption)
                success({ msg: resp["response_text"], code: resp["response_code"], gift: gift.web_serialize,
                    token: gift.token, redemption: redemption })
            else
                status = :ok
                fail_web({ err: resp["response_code"], msg: resp["response_text"]})
            end
        else
            fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} cannot be redeemed"})
        end
        respond(status)
    end

    def redeem
        gift = Gift.includes(:merchant).find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            if params['data']
                server_inits = redeem_params["server"]
                amount = redeem_params["amount"]
                ticket_num = redeem_params["ticket_num"]
                qrcode = redeem_params["qrcode"]
                loc_id = (redeem_params["loc_id"].to_i > 0) ? redeem_params["loc_id"].to_i : nil
            end

            puts "gifts controller getting current_redemption"
            resp = Redeem.start(sync: true, gift: gift, amount: amount, loc_id: loc_id,
                client_id: @current_client.id, api: "web/v3/gifts/#{gift.id}/redeem")
            if resp['success']
                @current_redemption = resp['redemption']
            end

            if @current_redemption.present? && @current_redemption.r_sys != 2 && @current_redemption.gift_id == params[:id].to_i
                ra = Redeem.apply(gift: gift, redemption: @current_redemption, qr_code: qrcode,
                    ticket_num: ticket_num, server: server_inits, client_id: @current_client.id)
                resp = Redeem.complete(redemption: ra['redemption'], gift: ra['gift'],
                    pos_obj: ra['pos_obj'], client_id: @current_client.id)
                if !resp.kind_of?(Hash)
                    status = :bad_request
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
                elsif resp["success"] == true
                    gift.fire_after_save_queue(@current_client)
                    status = :ok
                    if @current_redemption.r_sys == 1
                        success gift.web_serialize
                    else
                        success({msg: resp["response_text"]})
                    end
                else
                    status = :ok
                    fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                end
            else
                status = :ok
                fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} has a technical issue.  Please contact support at support@itson.me or on Get Help tab in app" })
            end

        else
            fail_message = if (gift.status == 'redeemed' && (gift.receiver_id == @current_user.id))
                "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
            else
                "Gift at #{gift.provider_name} cannot be redeemed"
            end
            fail_web({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

    def complete_redemption
        puts "\n IN complete_redemption - #{params.inspect}"
                # set the data
        redemption_id = (redemption_params["redemption_id"].to_i > 0) ? redemption_params["redemption_id"].to_i : nil
        server_inits = redemption_params["server"]
        ticket_num = redemption_params["ticket_num"]
        qrcode = redemption_params["qrcode"]
            # amount && loc_id are on the redemption
        amount = redemption_params["amount"]
        loc_id = (redemption_params["loc_id"].to_i > 0) ? redemption_params["loc_id"].to_i : nil

        @current_redemption = nil
            # find the redemption
        if redemption_id.present?
            @current_redemption = Redemption.includes([:merchant, :gift]).find(redemption_id)
        else
            gift = Gift.includes(:merchant).find(params[:id])
            @current_redemption = Redemption.current_pending_redemption(gift)
            if @current_redemption.nil?
                resp = Redeem.start(sync: true, gift: gift, amount: amount, loc_id: loc_id,
                    client_id: @current_client.id, api: "web/v3/gifts/#{gift.id}/complete_redemption")
                if resp['success']
                    @current_redemption = resp['redemption']
                end
            else
                # what if current pending R != amount or loc ?
            end
        end
        if @current_redemption.present? && @current_redemption.r_sys != 2 && @current_redemption.gift_id == params[:id].to_i
            gift ||= @current_redemption.gift
            if (gift.receiver_id == @current_user.id) && (gift.status != 'redeemed')
                if @current_redemption.redeemable? && @current_redemption.gift_id == gift.id

                    ra = Redeem.apply(gift: gift, redemption: @current_redemption, qr_code: qrcode,
                        ticket_num: ticket_num, server: server_inits, client_id: @current_client.id)
                    resp = Redeem.complete(redemption: ra['redemption'], gift: ra['gift'],
                        pos_obj: ra['pos_obj'], client_id: @current_client.id)

                    if !resp.kind_of?(Hash)
                        status = :bad_request
                        fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
                    elsif resp["success"] == true
                        gift.fire_after_save_queue(@current_client)
                        status = :ok
                        success({ msg: resp["response_text"], code: resp["response_code"], gift: gift.web_serialize,
                            token: @current_redemption.token, redemption: @current_redemption })
                    else
                        status = :ok
                        fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                    end
                else
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} cannot be redeemed (B651) " })
                end
            else
                if (gift.receiver_id != @current_user.id)
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} cannot be redeemed (R897)" })
                else
                    fail_web({ err: "ALREADY_REDEEMED", msg: "Gift #{gift.token} at #{gift.provider_name} has already been redeemed" })
                end
            end
        else
            fail_web({ err: "NOT_REDEEMABLE", msg: "Gift at #{gift.provider_name} has a technical issue.  Please contact support at support@itson.me or on Get Help tab in app" })
        end
        respond(status)
    end

    def redemptions
        gift = Gift.find params[:id]
        _serialized = gift.redemptions.serialize_objs
        success(_serialized)
        respond
    end

    def current_redemption
        gift = Gift.find params[:id]
        @current_redemption = Redemption.where(gift_id: gift.id).where('created_at > ?', 2.minutes.ago).last
        puts "\n IN current_redemption - #{@current_redemption.inspect}"
        if @current_redemption.status == 'done' && @current_redemption.response.kind_of?(Hash)
            resp = @current_redemption.response
            if resp["success"] == true
                gift.fire_after_save_queue(@current_client)
                success({msg: resp["response_text"]})
            else
                fail_web({ err: resp["response_code"], msg: resp["response_text"]})
            end
        else
            fail_web({ err: "RESET_CONTENT", msg: 'Data is processing please refresh screen'})
        end
        respond(:ok)
    end

private

    def set_origin gps, gift_hsh
        gift_hsh["link"] = gps[:link] || nil
        if gps[:origin]
            gift_hsh["origin"] = gps[:origin]
        else
            if gift_hsh["link"]
                gift_hsh["origin"] = gift_hsh["link"]
            else
                gift_hsh["origin"] = request.headers['User-Agent']
            end
        end
        gift_hsh["client_id"]     = @current_client.id
        gift_hsh["partner_id"]    = @current_partner.id
        gift_hsh["partner_type"]  = @current_partner.class.to_s
    end

    def set_receiver gps, gift_hsh
        gift_hsh["receiver_name"] = gps[:rec_name]
        gift_hsh["receiver_phone"] = gps[:rec_phone] if !gps[:rec_phone].blank?
        gift_hsh["receiver_email"] = gps[:rec_email] if !gps[:rec_email].blank?

        case gps[:rec_net]
        when "em"
            gift_hsh["receiver_email"] = gps[:rec_net_id]
        when "ph"
            gift_hsh["receiver_phone"] = gps[:rec_net_id]
        when "fb"
            gift_hsh["receiver_oauth"] = {}
            gift_hsh["receiver_oauth"]["network"] = "facebook"
            gift_hsh["receiver_oauth"]["network_id"] = gps[:rec_net_id]
            gift_hsh["receiver_oauth"]["token"]   = gps[:rec_token]
            gift_hsh["receiver_oauth"]["photo"]   = gps[:rec_photo]
            gift_hsh['facebook_id'] = gps[:rec_net_id]
        when "io"
            gift_hsh["receiver_id"] = gps[:rec_net_id]
        when "tw"
            gift_hsh["receiver_oauth"] = {}
            gift_hsh["receiver_oauth"]["network"] = "twitter"
            gift_hsh["receiver_oauth"]["network_id"] = gps[:rec_net_id]
            gift_hsh["receiver_oauth"]["token"]   = gps[:rec_token]
            gift_hsh["receiver_oauth"]["secret"]  = gps[:rec_secret]
            gift_hsh["receiver_oauth"]["handle"]  = gps[:rec_handle]
            gift_hsh["receiver_oauth"]["photo"]   = gps[:rec_photo]
            gift_hsh['twitter'] = gps[:rec_net_id]
        end
    end

    def promo_params
        params.require(:data).permit(:code)
    end

    def regift_params
        params.require(:data).permit(:link, :rec_net, :rec_net_id, :rec_token, :rec_secret, :rec_handle, :rec_photo, :rec_name, :msg, :cat, :scheduled_at)
    end

    def gift_params
        params.require(:data).permit(:merchant_id, :link, :rec_email, :rec_phone, :rec_net, :rec_net_id, :rec_token, :rec_secret, :rec_handle, :rec_photo, :rec_name, :scheduled_at, :msg, :cat, :pay_id, :value, :service, :loc_id, :loc_name, :items =>["detail", "price", "quantity", "item_id", "item_name"])
    end

    def redemption_params
        params.require(:data).permit(:server, :loc_id, :ticket_num, :amount, :qrcode, :redemption_id)
    end

    def redeem_params
        if params['data']
            params.require(:data).permit(:server, :loc_id, :ticket_num, :amount, :qrcode)
        else
            {}
        end
    end

    def rescue_from_timeout(exception)

        puts "\n IN GIFTSCONTROLLERTIMEOUT - #{@current_redemption.inspect}"
        status = :ok
        if @current_redemption.nil?
            fail_web({ err: "REQUEST_TIMEOUT", msg: 'Server is slow, please retry'})
        else
            @current_redemption.reload
            puts "\n IN GIFTSCONTROLLERRELOAD - #{@current_redemption.inspect}"
            if @current_redemption.status == 'done' && @current_redemption.response.kind_of?(Hash)
                resp = @current_redemption.response
                if resp["success"] == true
                    gift.fire_after_save_queue(@current_client)
                    success({msg: resp["response_text"]})
                else
                    fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                end
            elsif @current_redemption.status == 'pending'
                fail_web({ err: "RESET_CONTENT", msg: "Redemption is processing, gift value will set to #{display_money(cents: @current_redemption.gift_next_value, ccy: @current_redemption.ccy)} after redemption approved"})
            else
                fail_web({ err: "RESET_CONTENT", msg: 'Data is processing please refresh screen'})
            end
        end
        respond(status)
    end
end
