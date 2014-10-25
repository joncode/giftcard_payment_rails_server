class Mt::V2::MerchantsController < JsonController
    before_action :authenticate_merchant_tools, except: [:create, :reconcile_merchants]
    before_action :authenticate_general_token,  only:   [:create, :reconcile_merchants]
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil  if data_not_hash?

        provider     = Provider.new merchant_params
        if provider.save
            success provider.id
        else
            fail    provider.errors.messages
        end
        respond
    end

    def update
        return nil  if data_not_hash?

        if @provider.update_attributes(merchant_params)
            success   "Merchant Update Successful"
        else
            fail      @provider
        end
        respond
    end

    def menu
        menu_hsh = params["data"]
        menu_str = @provider.menu_string
        if menu_str.update_attributes(menu: menu_hsh)
            success   "Menu Update Successful"
        else
            fail      menu_str.errors.messages
        end

        respond
    end

    def reconcile

    end

private

    def merchant_params
        allowed = ["r_sys", "menu", "latitude", "longitude", "name", "zinger", "description", "address", "city", "state", "zip", "region_id", "phone", "merchant_id", "token", "image", "mode", "pos_merchant_id"]
        params.require(:data).permit(allowed)
    end

end