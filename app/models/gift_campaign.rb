class GiftCampaign < Gift

    validate :reserve_remaining


    def reserve_remaining
        unless CampaignItem.find(payable_id).reserve > 0
            errors.add(:payable_id, "reserve is empty. No more gifts can be created under this campaign item.")
        end
    end

private

    def pre_init args={}
        campaign_item         = CampaignItem.find(args["payable_id"])
        args["shoppingCart"]  = JSON.parse campaign_item.shoppingCart
        args["provider_id"]   = campaign_item.provider_id
        provider = Provider.find(args["provider_id"])
        args["provider_name"] = provider.name
        args["payable_id"]    = campaign_item.id
        args["payable_type"]  = "CampaignItem"
        args["value"]         = campaign_item.value
        args["cost"]          = campaign_item.cost
        args["giver_type"]    = campaign_item.giver_type
        args["giver_id"]      = campaign_item.giver_id
        args["giver_name"]    = campaign_item.giver_name
    end

    def post_init args={}
        puts "NOTIFY RECEIVER VIA #{self.receiver_email}"
    end
    
end