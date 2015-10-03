class Web::V3::GiftsController < MetalCorsController

    before_action :authentication_token_required
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

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
                ##### DO NOT CHANGE THIS -- >  gifts.serialize_objs(:web) !! without changing GiftAfterSave
            _serialized = gifts.serialize_objs(:web)
            success(_serialized)
            RedisWrap.set_user_gifts(@current_client.id, @current_user.id, _serialized)
        else
            success cache_resp
        end
        respond
    end

    def create
        gift_hash = {}
        gps = gift_params
        case gps[:rec_net]
        when "em"
            gift_hash["receiver_email"] = gps[:rec_net_id]
        when "ph"
            gift_hash["receiver_phone"] = gps[:rec_net_id]
        when "fb"
            gift_hash["receiver_oauth"] = {}
            gift_hash["receiver_oauth"]["network"] = "facebook"
            gift_hash["receiver_oauth"]["network_id"] = gps[:rec_net_id]
            gift_hash["receiver_oauth"]["token"]   = gps[:rec_token]
            gift_hash["receiver_oauth"]["photo"]   = gps[:rec_photo] if gps[:rec_photo]
        when "io"
            gift_hash["receiver_id"] = gps[:rec_net_id]
        when "tw"
            gift_hash["receiver_oauth"] = {}
            gift_hash["receiver_oauth"]["network"] = "twitter"
            gift_hash["receiver_oauth"]["network_id"] = gps[:rec_net_id]
            gift_hash["receiver_oauth"]["token"]   = gps[:rec_token]
            gift_hash["receiver_oauth"]["secret"]  = gps[:rec_secret]
            gift_hash["receiver_oauth"]["handle"]  = gps[:rec_handle]
            gift_hash["receiver_oauth"]["photo"]   = gps[:rec_photo] if gps[:rec_photo]
        end
        gift_hash["shoppingCart"]  = gps[:items]
        gift_hash["giver"]         = @current_user
        gift_hash["credit_card"]   = gps[:pay_id]
        gift_hash["receiver_name"] = gps[:rec_name]
        gift_hash["merchant_id"]   = gps[:loc_id]
        gift_hash["value"]         = gps[:value]
        gift_hash["message"]       = gps[:msg]
        gift_hash["link"]          = gps[:link] || nil
        if gps[:origin]
            gift_hash["origin"] = gps[:origin]
        else
            if gift_hash["link"]
                gift_hash["origin"] = gift_hash["link"]
            else
                gift_hash["origin"] = "www.itson.me"
            end
        end

        gift_hash["client_id"]     = @current_client.id
        gift_hash["partner_id"]    = @current_partner.id
        gift_hash["partner_type"]  = @current_partner.class.to_s
        gift = GiftSale.create(gift_hash)
        if gift.kind_of?(Gift) && !gift.id.nil?
            # binding.pry
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
        gift = Gift.find params[:id]
        if gift.notifiable? && (gift.receiver_id == @current_user.id)
            gift.notify(false)
            Relay.send_push_thank_you gift
            success gift.web_serialize
        else
            fail_message = if gift.status == 'redeemed'
                    "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
                else
                    "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
                end
            fail_web({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

    def notify
        gift = Gift.find params[:id]
        if gift.notifiable? && (gift.receiver_id == @current_user.id)
            if params["data"]
                loc_id = redeem_params["loc_id"]
            end
            gift.notify(true, loc_id)
            success gift.notify_serialize
        else
            fail_message = if gift.status == 'redeemed'
                    "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
                else
                    "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
                end
            fail_web({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

# {
#                 amount_applied: 8.00,
#                 total_check_amount: 8.00,
#                 remaining_check_balance: 0,
#                 remaining_gift_balance: 12.00
# }

    def redeem
        gift = Gift.find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            if params['data']
                server_inits = redeem_params["server"]
                loc_id = redeem_params["loc_id"]
                if  loc_id.nil?
                    merchant = gift.merchant
                else
                    merchant = Merchant.find(loc_id)
                end
            else
                merchant = gift.merchant
            end

            if merchant.nil?
                status = :bad_request
                fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
            elsif merchant.r_sys == 3
                if ticket_num = redeem_params["ticket_num"]
                    resp = gift.pos_redeem(ticket_num, merchant.pos_merchant_id, merchant.tender_type_id, loc_id)
                    if !resp.kind_of?(Hash)
                        status = :bad_request
                        fail({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
                    elsif resp["success"] == true
                        status = :ok
                        success({msg: resp["response_text"]})
                    else
                        status = :ok
                        fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                    end
                else
                    status = :bad_request
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Ticket Number not found"})
                end
            else
                gift.redeem_gift(server_inits, loc_id)
                success gift.web_serialize
            end
        else
            fail_message = if gift.status == 'redeemed'
                "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
            else
                "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
            end
            fail_web({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

private

    def notify_params
        params.require(:data).permit(:loc_id)
    end

    def pos_redeem_params
        params.require(:data).permit(:ticket_num, :loc_id)
    end

    def gift_params
        params.require(:data).permit(:merchant_id, :link, :rec_net, :rec_net_id, :rec_token, :rec_secret, :rec_handle, :rec_photo, :rec_name,:msg, :cat, :pay_id, :value, :service, :loc_id, :loc_name, :items =>["detail", "price", "quantity", "item_id", "item_name"])
    end

    def redeem_params
        params.require(:data).permit(:server, :loc_id, :ticket_num)
    end

end
