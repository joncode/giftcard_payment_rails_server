class Pos::V1::OrdersController < JsonController
    http_basic_authenticate_with name: NEXT_GEN_USER, password: NEXT_GEN_PASS

    def create
        puts "------------- params = #{params}"
        order = Order.init_with_pos(create_params)
        # this method should rturn text to the machine and maybe status but not this introspection
        if order.id.present?
            success({"voucher_value" => order.gift.value} )
        else
            fail order
        end
        respond(status)
    end

private

    def create_params
        params.require(:data).permit(:pos_merchant_id, :ticket_value, :redeem_code, :server_code, :ticket_item_ids)
    end
end

