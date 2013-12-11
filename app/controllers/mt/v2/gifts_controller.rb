class Mt::V2::GiftsController < JsonController
    before_filter :authenticate_merchant_tools
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil if collection_bad_request
        return nil if data_not_hash?(params["data"])
        allowed = ["receiver_name", "receiver_email", "shoppingCart", "message"]
        return nil if reject_if_not_exactly(allowed)
        convert_if_json(params["data"]["shoppingCart"])
        gift_hsh = gift_params
        gift_hsh["provider_id"] = @provider.id

        gift = GiftPromo.new(gift_hsh)
        if gift.save
            Relay.send_push_notification(gift)
            gift.notify_receiver
            success gift.promo_serialize
        else
            status = :bad_request
            fail gift
        end

        respond(status)
    end

private

    def gift_params
        allowed = ["receiver_name", "receiver_email", "shoppingCart", "message"]
        params.require(:data).permit(allowed)
    end

end

