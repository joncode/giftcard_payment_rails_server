class Admt::V2::ProvidersController < JsonController

    before_filter :authenticate_admin_tools

    def deactivate
        provider = Provider.unscoped.find(params[:id])

        if provider.deactivate
            merchant = provider.merchant
            merchant.active = false
            if merchant.save
                success   "#{provider.name} is now deactivated"
            else
                success   "#{provider.name} is now deactivated - Merchant tools site still active - please comtact Tech team"
            end
        else
            fail      provider.errors.full_messages
        end

        respond
    end

    def update_mode
        mode = ["live", "coming_soon", "paused"]
        if mode.include?(params[:data])
            provider = Provider.unscoped.find(params[:id])
            provider.mode = params[:data]
            if provider.save
                merchant = provider.merchant
                merchant.mode = params[:data]
                if merchant.save
                    success   "#{provider.name} is now #{provider.mode}"
                else
                    success   "#{provider.name} is now #{provider.mode} _ Merchant tools update failed - please contact Tech team"
                end
            else
                fail      provider.errors.full_messages
            end
        else
            fail "Incorrect merchant mode sent - < #{params[:data]} >"
        end
        respond
    end

end
