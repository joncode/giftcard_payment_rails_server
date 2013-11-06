class Mdot::V2::GiftsController < JsonController
    before_filter :authenticate_customer

    def index
        respond
    end

    def create
        respond
    end

    def regift
        respond
    end

    def archive
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

    def transactions
        respond
    end

    def open
        respond
    end

    def redeem
        respond

    end

end
