class Mt::V2::MerchantsController < JsonController
    before_filter :authenticate_merchant_tools, except: [:reconcile_merchants]
    before_filter :authenticate_general_token,  only:   [:reconcile_merchants]

    def update
        provider_hsh = params["data"]
        provider_hsh.delete("tz")
        if @provider.update_attributes(provider_hsh)
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
            fail      menu_str
        end

        respond
    end

    def reconcile

    end

end