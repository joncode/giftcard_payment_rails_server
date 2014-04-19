class Pos::V1::OrdersController < JsonController
    http_basic_authenticate_with name: NEXT_GEN_USER, password: NEXT_GEN_PASS

    def create
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



        # gift   = @current_user.received.where(id: params[:id]).first
        # return nil if data_not_found?(gift)
        # order = Order.init_with_gift(gift, server_code)
        # if order.save
        #     success({ "order_number" => order.make_order_num , "total" => gift.total,  "server" => order.server_code })
        # else
        #     fail order
        #     #status = :bad_request
        # end
        # respond(status)