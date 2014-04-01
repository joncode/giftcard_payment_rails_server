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

            if gp_mock.socials.count > 1
                gp_mock.emails.each do |email|
                    gift_hsh["receiver_email"] = email
                    create gift_hsh
                end
            elsif gp_mock.socials.count == 1

                gift_hsh["receiver_email"] = gp_mock.emails.first
                create gift_hsh
            elsif gp_mock.socials.count < 1
                status = :bad_request
                fail gp_mock
            end
        else
            status = :not_found
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

end

