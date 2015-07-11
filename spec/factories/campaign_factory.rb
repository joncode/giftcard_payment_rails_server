module CampaignFactory

	def affiliate_campaign
		campaign, campaign_item, provider = admin_campaign_and_item
		affiliate = FactoryGirl.create(:affiliate, url_name: "test_link")
		landing_page = FactoryGirl.create(:landing_page, link: "test_link-#{campaign.id}-1", campaign_id: campaign.id)
		return [campaign, campaign_item, provider, affiliate, landing_page]
	end

	def admin_campaign_and_item
		provider      = FactoryGirl.create(:merchant)
		admin         = FactoryGirl.create(:admin_user)
		admin_giver   = AdminGiver.find(admin.id)
		expiration    = (Time.now + 1.month).to_date
        campaign      = FactoryGirl.create(:campaign, purchaser_type: "AdminGiver",
                                                           purchaser_id: admin.id,
                                                           giver_name: admin_giver.name,
                                                           live_date: (Time.now - 1.week).to_date,
                                                           close_date: (Time.now + 1.week).to_date,
                                                           expire_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
        campaign_item = FactoryGirl.create(:campaign_item, merchant_id: provider.id,
                                                                campaign_id: campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                detail: "This gift is good until midnight.",
                                                                expires_at: expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"1\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                budget: 100,
                                                                value: "30",
                                                                cost: "3")
        return [campaign, campaign_item, provider]
	end

	def merchant_campaign_and_item
        provider      = FactoryGirl.create(:merchant, name: "LocationBar")
        giver         = FactoryGirl.create(:merchant, name: "GiverBar")
        biz_user      = BizUser.find(giver.id)
        expiration    = (Time.now + 1.month).to_date
        campaign      = FactoryGirl.create(:campaign, purchaser_type: "BizUser",
                                                       purchaser_id: giver.id,
                                                       giver_name: biz_user.name,
                                                       live_date: (Time.now - 1.week).to_date,
                                                       close_date: (Time.now + 1.week).to_date,
                                                       expire_date: (Time.now + 1.week).to_date,
                                                       budget: 100)
        campaign_item = FactoryGirl.create(:campaign_item, merchant_id: provider.id,
                                                            campaign_id: campaign.id,
                                                            message: "Enjoy this special gift on us!",
                                                            expires_at: expiration,
                                                            shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                            value: "30",
                                                            budget: 100,
                                                            cost:  "0")
        return [campaign, campaign_item, provider]
	end

end