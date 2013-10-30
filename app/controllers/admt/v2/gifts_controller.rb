class Admt::V2::GiftsController < JsonController

    before_filter :authenticate_admin_tools

    def update
        return nil  if data_not_hash?
        gift_params = strong_param(params["data"])
        return nil  if hash_empty?(gift_params)

        gift = Gift.find(params[:id])
        if gift.update_attributes(gift_params)
            success("#{gift.id} updated")
        else
            fail(gift)
        end
        respond
    end

    def refund
        gift = Gift.includes(:sale).find params[:id]
        sale = gift.sale
        resp = sale.void_sale
        if  resp == 0
            success "Gift is #{gift.pay_stat}"
        else
            fail resp
        end
        respond
    end

    def refund_cancel
        gift = Gift.includes(:sale).find params[:id]
        sale = gift.sale
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

end


