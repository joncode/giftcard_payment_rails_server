module GiftFactory

    def make_all_gifts merchant=nil
            # this creates status agnostic tons
        @start_date = Time.now - 1.month
        @user = FactoryGirl.create :user
        @admin_giver = FactoryGirl.create :at_user
        if merchant
            merchant_id = merchant.id
        else
            @make_all_gifts_merchant = FactoryGirl.create :merchant
            merchant_id = make_all_gifts_merchant.id
        end
        @biz_user = FactoryGirl.create :provider, merchant_id: merchant_id, payment_event: merchant.payment_event
        @provider = @biz_user
        campaign_admin = FactoryGirl.create :campaign, purchaser_type: "AdminGiver"
        campaign_item_admin = FactoryGirl.create :campaign_item, campaign_id: campaign_admin.id
        campaign_merchant = FactoryGirl.create :campaign, purchaser_type: "BizUser"
        campaign_item_merchant = FactoryGirl.create :campaign_item, campaign_id: campaign_merchant.id

        @sale                               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 300
        @sale_regifted_parent               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Sale", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 300
        @sale_regifted_child                = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @sale_regifted_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 301

        @admin                              = FactoryGirl.create :gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 100
        @admin_regifted_parent              = FactoryGirl.create :gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 100
        @admin_regifted_child               = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @admin_regifted_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 101

        @merchant                           = FactoryGirl.create :gift, giver_type: "BizUser", giver_id: @biz_user.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 200
        @merchant_regifted_parent           = FactoryGirl.create :gift, giver_type: "BizUser", giver_id: @biz_user.id, payable_type: "Debt", status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 200
        @merchant_regifted_child            = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @merchant_regifted_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 201

        @campaign_admin                     = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_admin.id, payable_type: "CampaignItem", payable_id: campaign_item_admin.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 150
        @campaign_admin_regifted_parent     = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_admin.id, payable_type: "CampaignItem", payable_id: campaign_item_admin.id, status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 150
        @campaign_admin_regifted_child      = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @campaign_admin_regifted_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 151

        @campaign_merchant                  = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_merchant.id, payable_type: "CampaignItem", payable_id: campaign_item_merchant.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 1.week, cat: 250
        @campaign_merchant_regifted_parent  = FactoryGirl.create :gift, giver_type: "Campaign", giver_id: campaign_merchant.id, payable_type: "CampaignItem", payable_id: campaign_item_merchant.id, status: "regifted", provider_id: @provider.id, created_at: @start_date + 1.week, cat: 250
        @campaign_merchant_regifted_child   = FactoryGirl.create :gift, giver_type: "User", giver_id: @user.id, payable_type: "Gift", payable_id: @campaign_merchant_regifted_parent.id, status: "redeemed", provider_id: @provider.id, redeemed_at: @start_date + 2.weeks, cat: 251

    end

    def make_gifts_with_children
        #         redeemed  expired regifted    total
        # origin  13        17      14          44
        # child1  3         5       6           14
        # child2  0         2       4           6
        # child3  3         0       1           4
        # child4  0         1       0           1
        # total   19        25      25          69
        @today         = Time.now.utc
        @campaign      = FactoryGirl.create :campaign, created_at: 10.days.ago, purchaser_type: "AdminGiver"
        @campaign_item = FactoryGirl.create :campaign_item, campaign_id: @campaign.id, created_at: 10.days.ago
        # 44.times { FactoryGirl.create :app_user }
        gifts_array = []
        44.times { gifts_array << FactoryGirl.create(:gift_campaign_bulk, payable_type: "CampaignItem", payable_id: @campaign_item.id, giver_type: "Campaign", giver_id: @campaign.id, giver_name: "Party Crew", receiver_name: "Happy", status: "redeemed", shoppingCart: @campaign_item.shoppingCart) }
        gifts_array[0..12].each do |gift|
            gift.update(status: "redeemed", redeemed_at: @today + 3.days)
        end
        gifts_array[13..29].each do |gift|
            gift.update(status: "expired")
        end

        child1_gifts = []
        gifts_array[30..43].each do |gift|
            gift.update(status: "regifted", redeemed_at: @today + 3.days )
            child1_gifts << FactoryGirl.create(:gift, payable_type: "Gift", payable_id: gift.id, status: "incomplete")
        end


        child1_gifts[0..2].each do |gift|
            gift.update(status: "redeemed", redeemed_at: @today + 3.days)
        end
        child1_gifts[3..7].each do |gift|
            gift.update(status: "expired")
        end
        child2_gifts = []
        child1_gifts[8..13].each do |gift|
            gift.update(status: "regifted", redeemed_at: @today + 3.days )
            child2_gifts << FactoryGirl.create(:gift, payable_type: "Gift", payable_id: gift.id, status: "incomplete")
        end

        child2_gifts[0..1].each do |gift|
            gift.update(status: "expired")
        end
        child3_gifts = []
        child2_gifts[2..5].each do |gift|
            gift.update(status: "regifted", redeemed_at: @today + 3.days )
            child3_gifts << FactoryGirl.create(:gift, payable_type: "Gift", payable_id: gift.id, status: "incomplete")
        end


        child3_gifts[0..2].each do |gift|
            gift.update(status: "redeemed", redeemed_at: @today + 3.days)
        end
        child3_regift = child3_gifts.last
        child3_regift.update(status: "regifted", redeemed_at: @today + 3.days )
        child4_gift = FactoryGirl.create(:gift, payable_type: "Gift", payable_id: child3_regift.id, status: "incomplete")
        child4_gift.update(status: "expired")
    end

    def make_at_dashboard_gifts
        gift_hash = {}
        7.times do |n|
            gift_hash[n] = FactoryGirl.create :gift
        end
        gift_hash[1].update(status: "open")
        gift_hash[2].update(status: "notified")
        gift_hash[3].update(status: "redeemed")
        gift_hash[4].update(status: "regifted")
        gift_hash[5].update(status: "expired")
        gift_hash[6].update(status: "cancel")

        7.times do |n|
            gift_hash[n] = FactoryGirl.create :gift, created_at: 2.days.ago
        end
        gift_hash[1].update(status: "open")
        gift_hash[2].update(status: "notified")
        gift_hash[3].update(status: "redeemed")
        gift_hash[4].update(status: "regifted")
        gift_hash[5].update(status: "expired")
        gift_hash[6].update(status: "cancel")

        7.times do |n|
            gift_hash[n] = FactoryGirl.create :gift, created_at: 2.weeks.ago
        end
        gift_hash[1].update(status: "open")
        gift_hash[2].update(status: "notified")
        gift_hash[3].update(status: "redeemed")
        gift_hash[4].update(status: "regifted")
        gift_hash[5].update(status: "expired")
        gift_hash[6].update(status: "cancel")

        7.times do |n|
            gift_hash[n] = FactoryGirl.create :gift, created_at: 2.months.ago
        end
        gift_hash[1].update(status: "open")
        gift_hash[2].update(status: "notified")
        gift_hash[3].update(status: "redeemed")
        gift_hash[4].update(status: "regifted")
        gift_hash[5].update(status: "expired")
        gift_hash[6].update(status: "cancel")
    end
end