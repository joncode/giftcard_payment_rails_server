class Web::V2::MerchantsController < JsonController
    before_filter :authenticate_www_token

    def show

        if provider = Provider.includes(:menu_string).where(merchant_id: params[:id]).first
            success provider.web_serialize
        else
            fail    data_not_found
        end
        respond

    end

private

    def authenticate_www_token
        token = request.headers["HTTP_TKN"]
        head :unauthorized unless WWW_TOKEN == token
    end

end