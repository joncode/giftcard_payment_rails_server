class Mt::V2::PhotosController < JsonController

    def update
        provider_hsh = params["data"]
        if @provider.update_attributes(provider_hsh)
            success   "Merchant Update Successful"
        else
            fail      @provider
        end

        respond
    end

end