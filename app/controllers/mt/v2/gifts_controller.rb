class Mt::V2::GiftsController < JsonController
    before_action :authenticate_merchant_tools
    rescue_from JSON::ParserError, :with => :bad_request


    def redeem
        redemption = Redemption.find_by(id: redeem_params["redemption_id"])
        if redemption.nil?
            fail "Redemption not found"
        else
            if redemption.status == 'pending'
                rc = Redeem.apply_and_complete(redemption: redemption, server: redeem_params['mt_user_id'])
                if rc['success']
                    success(rc['response_text'])
                else
                    fail rc['response_text']
                end
            else
                fail_message = if redemption.status == 'done'
                    "Redemption #{redemption.token} has already been redeemed"
                else
                    "Redemption #{redemption.token} is #{redemption.status}"
                end
                fail fail_message
            end
        end
        respond(status)
    end

    def proto_join
        pj = ProtoJoin.find create_with_proto_join_params[:proto_join_id]
        gift = GiftProtoJoin.create({ "proto_join" => pj })

        if gift.persisted?
             success({ "gift_id" => gift.id, "status" => gift.status})
        else
            fail "Gift not saved #{gift.errors.full_messages}"
        end

        respond
    end


private


    def create_with_proto_join_params
       params.require(:data).permit(:proto_join_id)
    end

    def redeem_params
        params.require(:data).permit :redemption_id, :mt_user_id #:gift_id, :token, :server
    end

end

