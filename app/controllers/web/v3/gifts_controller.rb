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
        gifts = Gift.get_user_activity(user)
        success(gifts.serialize_objs(:web))
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
        gift_hash["provider_id"]   = gps[:loc_id]
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

        gift = GiftSale.create(gift_hash)
        if gift.kind_of?(Gift) && !gift.id.nil?
            success gift.web_serialize
        else
            if gift.kind_of?(Gift)
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
            gift.notify
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

    def redeem
        gift = Gift.find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            server_inits = nil
            if params["data"]
                server_inits = redeem_params["server"]
            end
            gift.redeem_gift(server_inits)
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


# {
#                 amount_applied: 8.00,
#                 total_check_amount: 8.00,
#                 remaining_check_balance: 0,
#                 remaining_gift_balance: 12.00
# }

    def pos_redeem
        gift = Gift.includes(:provider).find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            if ticket_num = pos_redeem_params["ticket_num"]
                if !gift.provider.nil?
                    resp = gift.pos_redeem(ticket_num, gift.provider.pos_merchant_id, gift.provider.tender_type_id)
                    if resp["success"] == true
                        status = :ok
                        success({msg: resp["response_text"]})
                    else
                        status = :ok
                        fail_web({ err: resp["response_code"], msg: resp["response_text"]})
                    end
                else
                    status = :bad_request
                    fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
                end
            else
                status = :bad_request
                fail_web({ err: "NOT_REDEEMABLE", msg: "Ticket Number not found"})
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

    def pos_redeem_params
        params.require(:data).permit(:ticket_num)
    end

    def gift_params
        params.require(:data).permit(:link, :rec_net, :rec_net_id, :rec_token, :rec_secret, :rec_handle, :rec_photo, :rec_name,:msg, :cat, :pay_id, :value, :service, :loc_id, :loc_name, :items =>["detail", "price", "quantity", "item_id", "item_name"])
    end

    def redeem_params
        params.require(:data).permit(:server)
    end

end
