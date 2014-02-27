class GiftCampaign < Gift
    
    validate :is_giftable
    after_save :update_campaign_expire_date
    after_save :decrement_campaign_item_reserve

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
        args["giver_type"]    = "Campaign"
        args["giver_id"]      = campaign.id
        args["giver_name"]    = campaign.giver_name
        args["message"]       = campaign_item.message
        args["expires_at"]    = expires_at_calc(campaign_item.expires_at, campaign_item.expires_in)
    end

    def expires_at_calc expires_at, expires_in
        if expires_at.present?
            expires_at
        elsif expires_in.present?
            Time.now + expires_in.days
        end
    end

    def update_campaign_expire_date
        campaign = self.giver
        if self.expires_at.to_date > campaign.expire_date
            campaign.expire_date = self.expires_at.to_date
        end
        campaign.save
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

    def decrement_campaign_item_reserve
        self.payable.reserve -= 1
        self.payable.save
    end

end