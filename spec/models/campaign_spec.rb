require 'spec_helper'

describe Campaign do

    before(:each) do
        @merchant      = FactoryGirl.create(:merchant)
        @admin         = FactoryGirl.create(:admin_user)
        @admin_giver   = AdminGiver.find(@admin.id)
        @expiration    = (Time.now + 1.month).to_date
        @campaign      = FactoryGirl.create(:campaign, purchaser_type: "AdminGiver",
                                                       purchaser_id: @admin.id,
                                                       name: "Special Summer Party Campaign",
                                                       giver_name: "ItsOnMe Promotional Staff",
                                                       live_date: (Time.now - 1.week).to_date,
                                                       close_date: (Time.now + 1.week).to_date,
                                                       expire_date: (Time.now + 1.week).to_date,
                                                       budget: 100)
        @campaign_item = FactoryGirl.create(:campaign_item, merchant_id: @merchant.id,
                                                            campaign_id: @campaign.id,
                                                            message: "Enjoy this special gift on us!",
                                                            expires_at: @expiration,
                                                            shoppingCart: "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                            budget: 100,
                                                            value: "30")
        @gift_hsh = {}
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["payable_id"]     = @campaign_item.id
    end

    it_should_behave_like "gift serializer" do
        let(:object) { GiftCampaign.create(@gift_hsh) }
    end

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create(:campaign) }
    end

    describe "status booleans" do

        it "should be live when today in between start and close" do
            campaign = FactoryGirl.build(:campaign)
            campaign.is_new?.should be_false
            campaign.is_live?.should be_true
            campaign.is_closed?.should be_false
            campaign.is_expired?.should be_false
            campaign.status.should == "live"
        end

        it "should be new when today is before start" do
            start_date = Time.now.utc + 1.day
            campaign = FactoryGirl.build(:campaign, live_date:  start_date)
            campaign.is_new?.should be_true
            campaign.is_live?.should be_false
            campaign.is_closed?.should be_false
            campaign.is_expired?.should be_false
            campaign.status.should == "new"
        end

        it "should be closed when today is after close" do
            end_date = Time.now.utc - 2.days
            campaign = FactoryGirl.build(:campaign, close_date: end_date)
            campaign.is_new?.should be_false
            campaign.is_live?.should be_false
            campaign.is_closed?.should be_true
            campaign.is_expired?.should be_false
            campaign.status.should == "closed"
        end

        it "should be expired when today is after expiration" do
            end_date = Time.now.utc - 1.day
            campaign = FactoryGirl.build(:campaign, expire_date: end_date, close_date: end_date)
            campaign.is_new?.should be_false
            campaign.is_live?.should be_false
            campaign.is_closed?.should be_true
            campaign.is_expired?.should be_true
            campaign.status.should == "expired"
        end
    end

    context "attributes and validations" do

        let!(:campaign) { FactoryGirl.create(:campaign) }

        it "builds from factory" do
            campaign = FactoryGirl.build :campaign
            campaign.save
            campaign.should be_valid
        end

        it "has_many campaign_items" do
            ci1 = FactoryGirl.create(:campaign_item, campaign_id: campaign.id)
            ci2 = FactoryGirl.create(:campaign_item, campaign_id: campaign.id)
            campaign.campaign_items.count.should == 2
        end

        it "should know its gift_cat" do
            @campaign.gift_cat.should == 150
        end

        it "should have correct name and cname" do
            @campaign.name.should == "ItsOnMe Promotional Staff"
            @campaign.cname.should == "Special Summer Party Campaign"
        end
    end

end# == Schema Information
#
# Table name: campaigns
#
#  id             :integer         not null, primary key
#  type_of        :string(255)
#  status         :string(255)
#  name           :string(255)
#  notes          :text
#  live_date      :date
#  close_date     :date
#  expire_date    :date
#  purchaser_id   :integer
#  purchaser_type :string(255)
#  giver_name     :string(255)
#  photo          :string(255)
#  budget         :integer
#  created_at     :datetime
#  updated_at     :datetime
#  photo_path     :string(255)
#

