class Pos::V1::OrdersController < JsonController
    http_basic_authenticate_with name: NEXT_GEN_USER, password: NEXT_GEN_PASS
    rescue_from JSON::ParserError, :with => :bad_request
    rescue_from ActionController::ParameterMissing, :with => :bad_request

    def create
        redeem_code     = create_params["redeem_code"]
        pos_merchant_id = create_params["pos_merchant_id"]
        redeem = Redeem.includes(:gift).where(redeem_code: redeem_code.to_s).first
        if redeem && redeem.gift.provider.pos_merchant_id == pos_merchant_id.to_i
            order = Order.init_with_pos(create_params, redeem)
            if order.save
                status = :ok
                response_message = success({"voucher_value" => order.gift.value} )
            else
                status = :bad_request
                response_message = fail(order)
            end
        else
            status = :not_found
            response_message = fail("Error - Gift Conﬁrmation No. is not valid.")
        end
        redeem_id              = redeem.id if redeem.present?
        Ditto.receive_pos_create(params[:data], response_message, redeem_id, status)
        respond(status)
    end

private

    def create_params
        params.require(:data).permit(:pos_merchant_id, :ticket_value, :redeem_code, :server_code, :ticket_item_ids)
    end
end

