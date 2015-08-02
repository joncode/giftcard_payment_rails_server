class Mt::V2::MerchantsController < JsonController
    before_action :authenticate_merchant_tools, except: [:create, :reconcile_merchants]
    before_action :authenticate_general_token,  only:   [:create, :reconcile_merchants]
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil  if data_not_hash?

        merchant     = Merchant.new merchant_params
        if merchant.save
            success merchant.id
        else
            fail    merchant.errors.messages
        end
        respond
    end

    def update
        return nil  if data_not_hash?

        if @merchant.update(merchant_params)
            success   "Merchant Update Successful"
        else
            fail      @merchant
        end
        respond
    end

    def menu
        menu_hsh = params["data"]
        menu_str = @merchant.menu_string
        if menu_str.update(menu: menu_hsh)
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

        allowed = ["city_id", "rate", "r_sys", "menu_id", "latitude", "longitude", "name", "zinger", "description", "address", "city", "state", "zip", "region_id", "phone", "token", "image", "mode", "pos_merchant_id", "photo_l"]

        params.require(:data).permit(allowed)
    end

end