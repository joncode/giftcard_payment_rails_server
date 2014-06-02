class Mdot::V2::GiftsController < JsonController
    before_action :authenticate_customer

    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActiveModel::ForbiddenAttributesError, :with => :bad_request

    def archive
        give_gifts, rec_gifts  = Gift.get_archive(@current_user)
        give_ary = give_gifts.serialize_objs(:giver)
        rec_ary  = rec_gifts.serialize_objs(:receiver)
        success({"sent" => give_ary, "used" => rec_ary })
        respond
    end

    def badge
        gift_array  = Gift.get_gifts(@current_user)
        badge       = gift_array.size
        if badge > 0
            success({ "badge" => badge, "gifts" => gift_array.serialize_objs(:badge) })
        else
            success({ "badge" => 0 })
        end
        respond
    end

    def open
        gift   = @current_user.received.where(id: params[:id]).first
        return nil if params_bad_request
        return nil if data_not_found?(gift)

        time = Time.now 
        redeem = Redeem.find_or_create_with_gift(gift)
        if redeem
            if redeem.created_at >= time 
                Relay.send_push_thank_you gift
            end
            success(redeem.redeem_code)
        else
            fail redeem
        end
        respond
    end

    def redeem
        return nil if params_bad_request(["server"])
        server_code = redeem_params
        gift   = @current_user.received.where(id: params[:id]).first
        return nil if data_not_found?(gift)
        order = Order.init_with_gift(gift, server_code)
        if order.save
            success({ "order_number" => order.make_order_num , "total" => gift.total,  "server" => order.server_code })
        else
            fail database_error_redeem
            #status = :bad_request
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

    def redeem_params
        if params["server"].blank?
            nil
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
