require 'date'

class Mdot::V2::GiftsController < JsonController
    before_action :authenticate_customer

    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActiveModel::ForbiddenAttributesError, :with => :bad_request

    def index
        date_in_seconds = params[:since].present? ? params[:since].to_i : 0
        last_update     = Time.at(date_in_seconds).to_datetime

        gifts = @current_user.sent.where("updated_at > ?", last_update) + @current_user.received.where("updated_at > ?", last_update)
        gifts.uniq!
        success(gifts.serialize_objs(:client))
        respond
    end

    def archive
        give_gifts, rec_gifts  = Gift.get_archive(@current_user)
        give_ary = give_gifts.serialize_objs(:giver)
        rec_ary  = rec_gifts.serialize_objs(:receiver)
        success({"sent" => give_ary, "used" => rec_ary })
        respond
    end

    def badge
        if params[:pn_token] && params[:pn_token].length > 22
            Resque.enqueue(CreatePnTokenJob, @current_user.id, params[:pn_token], params[:platform])
        end
        gift_array  = Gift.get_gifts(@current_user)
        badge       = gift_array.count
        if gift_array.count > 0
            success({ "badge" => badge, "gifts" => gift_array.serialize_objs(:badge) })
        else
            success({ "badge" => 0 })
        end
        respond
    end

    def open  # redeption v1 && v2
        gift   = @current_user.received.where(id: params[:id]).first
        return nil if params_bad_request
        return nil if data_not_found?(gift)

        send_open_push = gift.status == 'open'

        if gift.notify(false)
            Relay.send_push_thank_you(gift) if send_open_push
            success(gift.token)
        else
            if !gift.notifiable?
                fail "Gift #{gift.token} at #{gift.provider_name} is #{gift.status}"
            else
                fail gift
            end
            #status = :unprocessable_entity
        end
        respond(status)
    end

    def notify  # redemption v2 ONLY


        gift   = @current_user.received.where(id: params[:id]).first
        return nil if params_bad_request
        return nil if data_not_found?(gift)

        if gift.notifiable?
            gift.notify
            success({ token:  gift.token, notified_at: gift.notified_at, new_token_at: gift.new_token_at })
        else
            fail "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
            status = :unprocessable_entity
        end
        respond(status)
    end

    def pos_redeem
        return nil if params_bad_request(["ticket_num"])
        gift = Gift.includes(:provider).find params[:id]
        if (gift.status == 'notified') && (gift.receiver_id == @current_user.id)
            if ticket_num = pos_redeem_params
                if !gift.provider.nil?
                    resp = gift.pos_redeem(ticket_num, gift.provider.pos_merchant_id, gift.provider.tender_type_id)
                    if resp["success"] == true
                        status = :ok
                        success(resp["response_text"])
                    else
                        status = :ok
                        fail(resp["response_text"])
                    end
                else
                    status = :bad_request
                    fail( "Merchant is currently not active please contact support@itson.me")
                end
            else
                status = :bad_request
                fail( "Ticket Number not found on request")
            end
        else
            fail_message = if gift.status == 'redeemed'
                "Gift #{gift.token} at #{gift.provider_name} has already been redeemed"
            else
                "Gift #{gift.token} at #{gift.provider_name} cannot be redeemed"
            end
            fail({ err: "NOT_REDEEMABLE", msg: fail_message})
        end
        respond(status)
    end

    def redeem  # redemption v1 ONLY
        return nil if params_bad_request(["server"])
        request_server = redeem_params
        gift           = @current_user.received.where(id: params[:id]).first

        if gift
            if gift.status == 'notified'
                if true # gift.token == request_params["token"]
                    gift.redeem_gift(request_server)
                    # gift.reload
                    success({ "order_number" => gift.token , "total" => gift.value,  "server" => gift.server })
                else
                    fail "Token is incorrect for gift #{params[:id]}"
                end
            else
                fail_message = if gift.status == 'redeemed'
                    "Gift #{gift.token} has already been redeemed"
                else
                    "Gift #{gift.token} cannot be redeemed"
                end
                status =  :unprocessable_entity
                fail fail_message
            end
        else
            fail database_error_redeem
            status = :not_found
        end
        respond(status)
    end

    def regift
        return nil if params_bad_request
        data = regift_params

        if data["receiver"].nil? || data["receiver"].kind_of?(String)
            bad_request
            return nil
        else
            new_gift_hsh = data["receiver"]
        end

        new_gift_hsh["message"]     = data["message"]
        new_gift_hsh["old_gift_id"] = params[:id]
        gift_response = GiftRegift.create(new_gift_hsh)

        if gift_response.kind_of?(Gift)
            if gift_response.id.nil?
                fail    gift_response
                if gift_response.errors.messages == {:receiver=> ["No unique receiver data. Cannot process gift. Please re-log in if this is an error."]}
                    status = :bad_request
                end
            else
                success gift_response.giver_serialize
            end
        else
            fail gift_response
            status = :forbidden
        end
        respond(status)
    end

    def create
        return nil if params_bad_request(["data", "shoppingCart"])
        return nil if nil_key_or_value(params["data"])
        return nil if nil_key_or_value(params["shoppingCart"])
        gift_hsh     = convert_if_json(params["data"])
        shoppingCart = convert_if_json(params["shoppingCart"])
        return nil if data_not_hash?(gift_hsh)
        return nil if data_not_array?(shoppingCart)

        gift_hsh = gift_params
        if promotional_gift_params? gift_hsh
            gift_response = "You cannot gift to the #{gift_hsh["receiver_name"]} account"
        else
            gift_hsh["shoppingCart"] = params["shoppingCart"]
            gift_hsh["giver"]        = @current_user
            gift_hsh["receiver_oauth"] = params['data']["receiver_oauth"]
            gift_hsh["origin"] = request.headers['User-Agent']
            gift_response = GiftSale.create(gift_hsh)
        end

        if gift_response.kind_of?(Gift)
            if gift_response.id
                success gift_response.giver_serialize
            else
                fail    gift_response
                #status = :bad_request
            end
        else
            fail gift_response
            status = :not_found
        end

        respond(status)
    end

private

    def promotional_gift_params? params_hsh
        if params_hsh["receiver_id"].nil?
            false
        else
            if params_hsh["receiver_name"].match(" Staff")
                begin
                    user = User.find(params_hsh["receiver_id"])
                    if user.last_name == "Staff"
                        false
                    else
                        true
                    end
                rescue
                    true
                end
            else
                false
            end
        end
    end

    def pos_redeem_params
        if params["ticket_num"].blank?
            nil
        else
            params.require(:ticket_num)
        end
    end

    def redeem_params
        if params["server"].blank?
            ""
        else
            params.require(:server)
        end
    end

    def regift_params
        params.require(:data).permit(:message, receiver: [:name, :receiver_id, :email, :phone, :facebook_id, :twitter, :receiver_email, :receiver_phone])
    end

    def gift_params
        if params.require(:data).kind_of?(String)
            JSON.parse(params.require(:data))
        else
            params.require(:data).permit(:message, :detail, :giver_id, :giver_name, :value, :service, :receiver_id, :receiver_email, :facebook_id, :twitter, :receiver_phone, :provider_name, :receiver_name, :provider_id, :credit_card,
                                         receiver_oauth: [:token, :secret, :network, :network_id, :handle, :photo])
        end
    end

end
