class Web::V2::MerchantsController < JsonController
    before_action :authenticate_www_token
    rescue_from JSON::ParserError, :with => :bad_request

    def show
        if merchant = Merchant.includes(:menu_string).where(id: params[:id]).first
            success merchant.web_serialize
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