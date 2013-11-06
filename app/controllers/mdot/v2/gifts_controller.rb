class Mdot::V2::GiftsController < JsonController
    before_filter :authenticate_customer

    def archive
        give_gifts, rec_gifts  = Gift.get_archive(@current_user)
        give_ary = give_gifts.serialize_objs(:giver)
        rec_ary  = rec_gifts.serialize_objs(:receiver)
        success({"sent" => give_ary, "used" => rec_ary })
        respond
    end

    def create
        respond
    end

    def regift
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

end
