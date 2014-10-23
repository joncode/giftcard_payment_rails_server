class Pos::V1::OrdersController < JsonController
    http_basic_authenticate_with name: NEXT_GEN_USER, password: NEXT_GEN_PASS
    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActionController::ParameterMissing, :with => :bad_request

    def create
        param_are       = create_params
        redeem_code     = param_are["redeem_code"]
        pos_merchant_id = param_are["pos_merchant_id"]
        server_code     = param_are["server_code"] || nil
        provider = Provider.find_by(pos_merchant_id: pos_merchant_id )
        if provider
            if gift = Gift.where(provider_id: provider.id, token: redeem_code).first
                if gift.redeem_gift(server_code)
                    status = :ok
                    response_message = success({"voucher_value" => gift.value} )
                else
                    status = :unprocessable_entity
                    response_message = fail("Gift #{gift.token} is already redeemed")
                end

            else
                status = :not_found
                response_message = fail("Error - Gift Conﬁrmation No. is not valid.")
            end
        else
            status = :not_found
            response_message = fail("Not Found")
        end
        gift_id = gift ? gift.id : nil
        Ditto.receive_pos_create(params[:data], response_message, gift_id, status)
        respond(status)
    end

private

    def create_params
        params.require(:data).permit(:pos_merchant_id, :ticket_value, :redeem_code, :server_code, :ticket_item_ids)
    end
end

