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
        merchant = Merchant.unscoped.find(params[:id])

        if merchant.deactivate
            success   "#{merchant.name} is now deactivated"
        else
            fail      merchant
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
            merchant = Merchant.unscoped.find(params[:id])
            merchant.mode = params[:data]
            if merchant.save
                success   "#{merchant.name} is now #{merchant.mode.humanize}"
            else
                fail      merchant
            end
        else
            fail "Incorrect merchant mode sent - < #{params[:data]} >"
        end
        respond
    end

private

    def provider_params
        params.require(:data).permit(:website, :tz, :tender_type_id, :rate, :name, :address, :city, :state, :zip, :region_id, :city_id, :phone, :zinger, :description, :pos_merchant_id)
    end


end
