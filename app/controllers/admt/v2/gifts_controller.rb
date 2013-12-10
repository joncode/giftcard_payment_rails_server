class Admt::V2::GiftsController < JsonController

    before_filter :authenticate_admin_tools

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
        sale = gift.payable
        resp = sale.void_sale
        if  resp == 0
            success "Gift is #{gift.pay_stat}"
        else
            fail resp
        end
        respond
    end

    def refund_cancel
        gift = Gift.includes(:payable).find params[:id]
        sale = gift.payable
        resp = sale.void_sale
        if  resp == 0
            gift.status = 'cancel'
            if gift.save
                success "Gift is #{gift.pay_stat} and cancelled"
            else
                success "Please contact tech support - Gift #{gift.id} is NOT Cancelled in APP ONLY"
            end
        else
            fail resp
        end
        respond
    end

private

    def strong_param(data_hsh)
        allowed = [ "receiver_name" , "receiver_email",  "receiver_phone" ]
        data_hsh.select{ |k,v| allowed.include? k }
    end

    def gift_params
        allowed = [ "receiver_name" , "receiver_email",  "receiver_phone" ]
        params.require(:data).permit(allowed)
    end

end


