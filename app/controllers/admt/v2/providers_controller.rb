class Admt::V2::ProvidersController < JsonController

    before_action :authenticate_admin_tools
    rescue_from JSON::ParserError, :with => :bad_request

    # def create
    #     provider = Provider.new(provider_params)
    #     if provider.save
    #         success   "#{provider.name} was created"
    #     else
    #         fail      provider
    #     end
    #     respond
    # end

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
            fail      provider
        end

        respond
    end

    def update
        provider = Provider.unscoped.find(params[:id])
        if provider.update(provider_params)
            success   "#{provider.name} updated"
        else
            fail      provider
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
                    success   "#{provider.name} is now #{provider.mode.humanize}"
                else
                    success   "#{provider.name} is now #{provider.mode.humanize} _ Merchant tools update failed - please contact Tech team"
                end
            else
                fail      provider
            end
        else
            fail "Incorrect merchant mode sent - < #{params[:data]} >"
        end
        respond
    end

private

    def provider_params
        params.require(:data).permit(:name, :address, :city, :state, :zip, :region_id, :phone, :zinger, :description, :pos_merchant_id)
    end


end
