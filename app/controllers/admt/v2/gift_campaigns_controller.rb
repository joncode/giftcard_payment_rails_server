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

    def bulk_create
        return nil if collection_bad_request
        return nil if data_not_hash?(gift_params)

        if CampaignItem.exists?(gift_params[:payable_id])
            campaign_item = CampaignItem.find(gift_params[:payable_id])
            response = RewardsGenerator.make_gifts [campaign_item.id]
            if response[:status] == "Gift Creation Successful"
                success "Created gifts for Campaign Item #{campaign_item.id}"
            else
                # status = :bad_request
                fail "ERROR: #{response[:status]}. A total of #{response[:created_gifts_count]} gifts were created."
            end
        else
            status = :not_found
            fail "Campaign Item #{gift_params[:payable_id]} could not be found"
        end
        respond(status)
    end

private

    def gift_params
        params.require(:data).permit(:receiver_phone, :receiver_email, :payable_id)
    end

end
