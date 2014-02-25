require 'spec_helper'

describe GiftCampaign do

    context "ItsOnMe Campaign" do
        before(:each) do
            Provider.delete_all
            @provider      = FactoryGirl.create(:provider)
            @admin         = FactoryGirl.create(:admin_user)
            @admin_giver   = AdminGiver.find(@admin.id)
            @expiration    = (Time.now + 1.month).to_date
            @campaign      = FactoryGirl.create(:campaign, purchaser_type: "AdminGiver",
                                                           purchaser_id: @admin.id,
                                                           giver_name: "ItsOnMe Promotional Staff",
                                                           live_date: (Time.now - 1.week).to_date,
                                                           close_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @provider.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                value: "30")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it "should create gift" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            gift_campaign.class.should          == GiftCampaign
            gift_campaign.message.should        == "Enjoy this special gift on us!"
            gift_campaign.receiver_name.should  == "Customer Name"
            gift_campaign.receiver_email.should == "customer@gmail.com"
            gift_campaign.provider_id.should    == @provider.id
            gift_campaign.provider_name.should  == @provider.name
            gift_campaign.giver_type.should     == "Campaign"
            gift_campaign.giver_id.should       == @campaign.id
            gift_campaign.giver_name.should     == "ItsOnMe Promotional Staff"
            gift_campaign.value.should          == "30"
        end

        it "should associate the CampaignItem as the payable" do
            gift = GiftCampaign.create @gift_hsh
            payable = gift.payable
            payable.class.name.should       == "CampaignItem"
            payable.owner.class.name.should == "Campaign"
            payable.success?.should    == true
            payable.resp_code.should   == 1
            payable.reason_text.should == "Transaction approved."
            payable.reason_code.should == 1
        end

        it "should not create gift if there is no reserve" do
            @campaign_item.update(reserve: 0)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should            == 1
            gift.errors.full_messages[0].should == "Payable Campaign Item reserve is empty. No more gifts can be created under this campaign item."
        end

        it "should not create gift if the campaign is not yet live" do
            @campaign.update(live_date: (Time.now + 1.day).to_date)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should == 1
            gift.errors.full_messages[0].should == "Payable Campaign is not live. No gifts can be created."
        end

        it "should not create gift if the campaign is closed" do
            @campaign.update(close_date: (Time.now - 1.day).to_date)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should == 1
            gift.errors.full_messages[0].should == "Payable Campaign is not live. No gifts can be created."
        end
    end

    context "Merchant Campaign" do
        before(:each) do
            Provider.delete_all
            @location      = FactoryGirl.create(:provider, name: "LocationBar")
            @giver         = FactoryGirl.create(:provider, name: "GiverBar")
            @biz_user      = BizUser.find(@giver.id)
            @expiration    = (Time.now + 1.month).to_date
            @campaign      = FactoryGirl.create(:campaign, purchaser_type: "BizUser",
                                                           purchaser_id: @giver.id,
                                                           giver_name: "Giver Promotion Staff",
                                                           live_date: (Time.now - 1.week).to_date,
                                                           close_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @location.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                value: "30")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it "should create gift" do
            gift_campaign = GiftCampaign.create(@gift_hsh)
            gift_campaign.class.should          == GiftCampaign
            gift_campaign.message.should        == "Enjoy this special gift on us!"
            gift_campaign.receiver_name.should  == "Customer Name"
            gift_campaign.receiver_email.should == "customer@gmail.com"
            gift_campaign.provider_id.should    == @location.id
            gift_campaign.provider_name.should  == "LocationBar"
            gift_campaign.giver_type.should     == "Campaign"
            gift_campaign.giver_id.should       == @campaign.id
            gift_campaign.giver_name.should     == "Giver Promotion Staff"
            gift_campaign.value.should          == "30"
        end

        it "should associate the CampaignItem as the payable" do
            gift = GiftCampaign.create @gift_hsh
            payable = gift.payable
            payable.class.name.should       == "CampaignItem"
            payable.owner.class.name.should == "Campaign"
            payable.success?.should    == true
            payable.resp_code.should   == 1
            payable.reason_text.should == "Transaction approved."
            payable.reason_code.should == 1
        end
    end

end