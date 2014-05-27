class Admt::V2::GiftsController < JsonController

    before_action :authenticate_admin_tools
    rescue_from JSON::ParserError, :with => :bad_request

    def update
        return nil  if data_not_hash?
        gift_param = strong_param(params["data"])
        return nil  if hash_empty?(gift_param)

        gift = Gift.find(params[:id])
        if gift.update_attributes(gift_params)
            success("#{gift.id} updated")
        else
            fail(gift)
        end
        respond
    end

    def add_receiver
        gift = Gift.find(params[:id])
        user = User.find(params[:data])

        if gift.receiver_id
                # change the receiver obj
            gift.remove_receiver
        else
                # merge a user with the gift receiver data and add receiver obj
            rec_hsh  = gift.receiver_info_as_hsh
            user_hsh = PeopleFinder.sanitize rec_hsh
            user.new_socials(user_hsh)
            user.save
        end

        gift.add_receiver(user)
        if gift.save
            success gift.admt_serialize
        else
            fail gift
        end
        respond
    end

    def refund
        gift = Gift.includes(:payable).find params[:id]
        resp_hsh = gift.void_refund_live
        if  resp_hsh["status"] > 0
            success "Gift is #{gift.pay_stat}"
        else
            fail resp_hsh["msg"]
        end
        respond
    end

    def refund_cancel
        gift = Gift.includes(:payable).find params[:id]
        resp_hsh = gift.void_refund_cancel
        if  resp_hsh["status"] > 0
            success "Gift is #{gift.pay_stat} and cancelled"
        else
            fail resp_hsh["msg"]
        end
        respond
    end

    def create
        return nil if collection_bad_request
        return nil if data_not_hash?(params["data"])
        allowed = ["receiver_name", "receiver_email", "shoppingCart", "message", "detail", "expires_at", "provider_id", "provider_name"]
        return nil if reject_if_not_exactly(allowed)
        convert_if_json(params["data"]["shoppingCart"])
        gift_hsh = gift_create_params(allowed)
        gift_hsh["giver"] = @admin_user.giver
        gift = GiftAdmin.create(gift_hsh)
        if gift.persisted?
            success gift.promo_serialize
        else
            status = :bad_request
            fail gift
        end

        respond(status)
    end

private

    def strong_param(data_hsh)
        allowed = [ "receiver_name" , "receiver_email",  "receiver_phone" ]
        data_hsh.select{ |k,v| allowed.include? k }
    end

    def gift_create_params allowed
        params.require(:data).permit(allowed)
    end

    def gift_params
        allowed = [ "receiver_name" , "receiver_email",  "receiver_phone" ]
        params.require(:data).permit(allowed)
    end

end


