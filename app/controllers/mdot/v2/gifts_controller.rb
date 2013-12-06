class Mdot::V2::GiftsController < JsonController
    before_filter :authenticate_customer

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
        redeem = Redeem.find_or_create_with_gift(gift)
        success(redeem.redeem_code)
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
            fail order
            status = :bad_request
        end
        respond(status)
    end

    def regift
        return nil if params_bad_request
        data = regift_params
        new_gift_hsh = data["receiver"]
        return nil if data_not_hash?(new_gift_hsh)
        return nil if params_required(new_gift_hsh)
        new_gift_hsh["message"]     = data["message"]
        new_gift_hsh["old_gift_id"] = params[:id]
        if gift_response = GiftRegift.create(new_gift_hsh)
            if gift_response.kind_of?(Gift)
                success gift_response.giver_serialize
            else
                fail gift_response
                status = :forbidden
            end
        else
            fail    gift
            status = :bad_request
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
        gift_hsh["shoppingCart"] = params["shoppingCart"]
        gift_hsh["giver"]        = @current_user
        gift_response = GiftSale.create(gift_hsh)

        if gift_response.kind_of?(Gift)
            if gift_response.id
                success gift_response.giver_serialize
            else
                fail    gift_response
                status = :bad_request
            end
        else
            fail gift_response
            status = :not_found
        end

        respond(status)
    end

private

    def redeem_params
        params.require(:server)
    end

    def regift_params
        params.require(:data).permit(:message, receiver: [:name, :receiver_id, :email, :phone, :facebook_id, :twitter])
    end

    def gift_params
        if params.require(:data).kind_of?(String)
            pg = JSON.parse(params.require(:data))
        else
            params.require(:data).permit( :giver_id,:giver_name,:value,:service,:receiver_id,:receiver_name,:provider_id,:credit_card)
        end
    end

end
