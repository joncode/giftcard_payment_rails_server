class Admt::V2::GiftsController < JsonController

    before_filter :authenticate_admin_tools

    def update
        # we do not have the criteria for this route yet

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

    def deactivate_all
        user = User.find(params[:user_id])
        total_gifts = Gift.get_user_activity(user)
        total_gifts.each do |gift|
            gift.active = false
            gift.save
        end

        if Gift.get_user_activity(user).count == 0
            success "Gifts Deactivated."
        else
            fail    "Error in batch delete gifts"
        end
        respond
    end

end


