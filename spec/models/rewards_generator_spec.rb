require 'spec_helper'
require 'rewards_generator'

describe RewardsGenerator do

    it "should get all the users and campaigns and make gifts" do
        Campaign.delete_all
        CampaignItem.delete_all
        provider = FactoryGirl.create(:provider)
        user1 = FactoryGirl.create(:user, first_name: "First", last_name: "Laszt")
        user2 = FactoryGirl.create(:user, first_name: "Second", last_name: "Laszt")
        user3 = FactoryGirl.create(:user, first_name: "Third", last_name: "Laszt")
        user4 = FactoryGirl.create(:user, first_name: "Fourth", last_name: "Laszt")

        campaign = FactoryGirl.create(:campaign, budget: 100)
        campaign_item = FactoryGirl.create(:campaign_item, textword: 'a', budget: 100, reserve: 100, campaign_id: campaign.id, provider_id: provider.id, value: "13", cost: "8")

        response = RewardsGenerator.make_gifts [campaign_item.id]
        response.should == { status: "Gift Creation Successful", created_gifts_count: 4}
        
        gifts = Gift.order('created_at DESC')
        gifts.each do |gift|
            ["First Laszt", "Second Laszt", "Third Laszt", "Fourth Laszt"].include?(gift.receiver_name).should be_true
            [user1.id,user2.id,user3.id,user4.id].include?(gift.receiver_id).should be_true
            gift.value.should == "13"
        end
        gifts.count.should == 4
    end

    it "should track the number of gifts and break from loop if reserve is reached" do
        provider = FactoryGirl.create(:provider)
        user1 = FactoryGirl.create(:user, first_name: "First", last_name: "Laszt")
        user2 = FactoryGirl.create(:user, first_name: "Second", last_name: "Laszt")
        user3 = FactoryGirl.create(:user, first_name: "Third", last_name: "Laszt")
        user4 = FactoryGirl.create(:user, first_name: "Fourth", last_name: "Laszt")

        campaign = FactoryGirl.create(:campaign, budget: 3)
        campaign_item = FactoryGirl.create(:campaign_item, textword: 'a', budget: 3, reserve: 3, campaign_id: campaign.id, provider_id: provider.id, value: "13", cost: "8")

        response = RewardsGenerator.make_gifts [campaign_item.id]
        response.should == { status: "Campaign items reserve was used up", created_gifts_count: 3}
        gifts = Gift.order('created_at DESC')
        gifts.each do |gift|
            ["First Laszt", "Second Laszt", "Third Laszt", "Fourth Laszt"].include?(gift.receiver_name).should be_true
            [user1.id, user2.id, user3.id, user4.id].include?(gift.receiver_id).should be_true
            gift.value.should == "13"
        end
        gifts.count.should == 3
    end

    it "should track the number of gifts and break from loop if and gifts fail to be created" do
        provider = FactoryGirl.create(:provider)
        user1 = FactoryGirl.create(:user, first_name: "First", last_name: "Laszt")
        user2 = FactoryGirl.create(:user, first_name: "Second", last_name: "Laszt")
        user3 = FactoryGirl.create(:user, first_name: "Third", last_name: "Laszt")
        user4 = FactoryGirl.create(:user, first_name: "Fourth", last_name: "Laszt")

        campaign = FactoryGirl.create(:campaign, budget: 3, status: "expired", close_date: Time.now - 1.day, expire_date: Time.now - 1.day)
        campaign_item = FactoryGirl.create(:campaign_item, textword: 'a', budget: 3, reserve: 3, campaign_id: campaign.id, provider_id: provider.id, value: "13", cost: "8")

        response = RewardsGenerator.make_gifts [campaign_item.id]
        response.should == { status: "[\"Campaign Vodka Special Campaign a is closed. No gifts can be created.\"]", created_gifts_count: 0}
        gifts = Gift.order('created_at DESC')
        gifts.count.should == 0
    end


end