class GiftCampaign < Gift

    validate :is_giftable

private

    def pre_init args={}
        campaign_item         = CampaignItem.includes(:campaign).includes(:provider).where(id: args["payable_id"]).first
        campaign              = campaign_item.campaign
        provider              = campaign_item.provider
        args["shoppingCart"]  = JSON.parse campaign_item.shoppingCart
        args["provider_id"]   = provider.id
        args["provider_name"] = provider.name
        args["payable_id"]    = campaign_item.id
        args["payable_type"]  = "CampaignItem"
        args["value"]         = campaign_item.value
        args["giver_type"]    = campaign.purchaser_type
        args["giver_id"]      = campaign.purchaser_id
        args["giver_name"]    = campaign.giver_name
        args["message"]       = campaign_item.message
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end
   
    def is_giftable
        campaign_item = CampaignItem.includes(:campaign).where(id: payable_id).first
        campaign_is_live campaign_item.campaign
        campaign_item_has_reserve campaign_item
    end

    def campaign_is_live campaign
        today = Time.now.to_date
        unless campaign.live_date < today && campaign.close_date > today
            errors.add(:payable_id, "Campaign is not live. No gifts can be created.")
        end
    end

    def campaign_item_has_reserve campaign_item
        unless campaign_item.reserve > 0
            errors.add(:payable_id, "Campaign Item reserve is empty. No more gifts can be created under this campaign item.")
        end
    end    
end