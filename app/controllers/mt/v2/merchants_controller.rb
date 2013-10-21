class Mt::V2::MerchantsController < JsonController
    before_filter :authenticate_merchant_tools, except: [:create, :reconcile_merchants]
    before_filter :authenticate_general_token,  only:   [:create, :reconcile_merchants]

    def create
        merchant_hsh = params["data"]
        if merchant_hsh.kind_of?(Hash)
            provider = Provider.new merchant_hsh
            if provider.save
                success provider.id
            else
                fail    provider.errors.messages
            end
        else
            fail  "No data sent"
        end
        respond
    end

    def update
        provider_hsh = params["data"]
        if provider_hsh.kind_of?(Hash)
            provider_hsh.delete("tz")
            if @provider.update_attributes(provider_hsh)
                success   "Merchant Update Successful"
            else
                fail      @provider
            end
        else
            fail  "No data sent"
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