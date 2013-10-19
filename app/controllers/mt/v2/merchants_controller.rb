class Mt::V2::MerchantsController < JsonController
    before_filter :authenticate_merchant_tools, except: [:create, :reconcile_merchants]
    before_filter :authenticate_general_token, only: [:create, :reconcile_merchants]

    def create

        merchant_hsh = params["data"]
        provider = Provider.new merchant_hsh
        if provider.save
            success provider.id
        else
            fail    provider.errors.messages
        end
        respond
    end

    def update
        provider_hsh = params["data"]
        if @provider.update_attributes(provider_hsh)
            success   "Merchant Update Successful"
        else
            fail      @provider
        end

        respond
    end

    def reconcile

    end

end