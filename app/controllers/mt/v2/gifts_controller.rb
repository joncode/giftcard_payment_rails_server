class Mt::V2::GiftsController < JsonController
    before_action :authenticate_merchant_tools
    rescue_from JSON::ParserError, :with => :bad_request

    def bulk_create
        return nil if collection_bad_request
        return nil if data_not_hash?(params["data"])
        allowed = ["gift_promo_mock_id"]
        return nil if reject_if_not_exactly(allowed)
        gp_mock_id = gift_params["gift_promo_mock_id"]
        if gp_mock = GiftPromoMock.find(gift_params["gift_promo_mock_id"])
            gift_hsh = gp_mock.gift_hsh
            gift_hsh["provider_id"] = @provider.id
            if gp_mock.socials.count >= 1
                ActiveRecord::Base.transaction do
                    gp_mock.emails.each do |email|
                        gift_hsh["receiver_email"] = email
                        create gift_hsh
                    end
                end
            elsif gp_mock.socials.count < 1
                status = :bad_request
                fail gp_mock
            end
        else
            status = :not_found
        end

        respond(status)
    end

    def redeem
        request_params = redeem_params
        gift_id        = request_params["gift_id"]
        gift           = Gift.find(gift_id)
        if gift.status == 'notified'
            if gift.token == request_params["token"]
                gift.redeem_gift(request_params["server"])
                success({ "gift_id" => gift.id, "status" => gift.status})
            else
                fail "Token is incorrect for gift #{gift_id}"
            end
        else
            fail_message = if gift.status == 'redeemed'
                "Gift #{gift_id} has already been redeemed"
            else
                "Gift #{gift_id} cannot be redeemed"
            end
            fail fail_message
        end
        respond(status)
    end

private

    def create gift_hsh
        gift = GiftPromo.new(gift_hsh)
        if gift.save
            success gift.promo_serialize
        else
            status = :bad_request
            fail gift
        end
    end

    def gift_params
        allowed = ["gift_promo_mock_id"]
        params.require(:data).permit(allowed)
    end

    def redeem_params
        params.require(:data).permit(:gift_id, :token, :server)
    end

end

