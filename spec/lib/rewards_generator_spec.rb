require 'spec_helper'
require 'rewards_generator'

describe RewardsGenerator do

    it "should get all the users and campaigns and make gifts" do
        Campaign.delete_all
        CampaignItem.delete_all
        provider1 = FactoryGirl.create(:provider)
        provider2 = FactoryGirl.create(:provider)
        FactoryGirl.create(:user, first_name: "Fifth", last_name: "Laszt")
        user1 = FactoryGirl.create(:user, first_name: "First", last_name: "Laszt")
        user2 = FactoryGirl.create(:user, first_name: "Second", last_name: "Laszt")
        user3 = FactoryGirl.create(:user, first_name: "Third", last_name: "Laszt")
        user4 = FactoryGirl.create(:user, first_name: "Fourth", last_name: "Laszt")

        campaign = FactoryGirl.create(:campaign, budget: 4)
        ci1 = FactoryGirl.create(:campaign_item, textword: 'a', budget: 2, reserve: 2, campaign_id: campaign.id, provider_id: provider1.id)
        ci1.update(reserve: 2)
        ci2 = FactoryGirl.create(:campaign_item, textword: 'b', budget: 2, reserve: 2, campaign_id: campaign.id, provider_id: provider2.id)
        ci2.update(reserve: 2)

        RewardsGenerator::make_gifts
        gifts = Gift.order('created_at DESC')
        gifts.each do |gift|
            ["First Laszt", "Second Laszt", "Third Laszt", "Fourth Laszt"].include?(gift.receiver_name).should be_true
            [user1.id,user2.id,user3.id,user4.id].include?(gift.receiver_id).should be_true
            gift.value.should == "13"
        end
        gifts.count.should == 4
    end
end