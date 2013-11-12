class Mdot::V2::GiftsController < JsonController
    before_filter :authenticate_customer

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
        gift   = Gift.find(params[:id])
        redeem = Redeem.find_or_create_with_gift(gift)
        success(redeem.redeem_code)
        respond
    end

    def redeem
        gift = Gift.find(params[:id])
        order = Order.init_with_gift(gift, params["server"])
        if order.save
            success({ "order_number" => order.make_order_num , "total" => gift.total,  "server" => order.server_code })
        else
            fail order
        end
        respond
    end

    def regift
        new_gift_hsh = convert_if_json(params["data"]["receiver"])
        new_gift_hsh["message"]   = params["data"]["message"]
        new_gift_hsh["regift_id"] = params[:id]

        gift_regifter  = GiftRegifter2.new(new_gift_hsh)
        if gift_regifter.create
            success gift_regifter.response
        else
            fail    gift_regifter.response
        end
        respond
    end


    def create
        gift = convert_if_json(params["gift"])
        shoppingCart = convert_if_json(params["shoppingCart"])

        if card = Card.where(id: gift["credit_card"]).count > 0
            gift_creator = GiftCreator.new(@current_user, gift, shoppingCart)
            unless gift_creator.no_data?
                gift_creator.build_gift
                if gift_creator.resp["error"].nil?
                    gift_creator.charge
                end
            end
            response = gift_creator.resp
            if response["success"]
                success response["success"]
            elsif response["error"]
                fail response["error"]
            elsif response["error_server"]
                fail response["error_server"]
            else
                fail response
            end
        else
            fail "We do not have that credit card on record.  Please choose a different card."
        end
        respond
    end
end
