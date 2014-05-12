class Admt::V2::GiftCampaignsController < JsonController

    before_action :authenticate_admin_tools
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil if collection_bad_request
        return nil if data_not_hash?(gift_params)

        if CampaignItem.exists?(gift_params[:payable_id])
            gift = GiftCampaign.create(gift_params)
            if gift.id.present?
                success gift.promo_serialize
            else
                # status = :bad_request
                fail gift
            end
        else
            status = :not_found
            fail "Campaign Item #{gift_params[:payable_id]} could not be found"
        end
        respond(status)
    end

private

    def gift_params
        params.require(:data).permit(:receiver_phone, :payable_id)
    end

end


