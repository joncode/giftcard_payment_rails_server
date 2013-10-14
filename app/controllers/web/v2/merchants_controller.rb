class Web::V2::MerchantsController < JsonController
    #before_filter :authenticate_www_token

    def show
        merchant = Provider.find params[:id]
        if merchant
            success merchant.web_serialize
        else
            fail data_not_found
        end
        respond
    end

end