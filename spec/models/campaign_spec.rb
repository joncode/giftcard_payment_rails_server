require 'spec_helper'

describe Campaign do

    context "gift_campaign messages" do

        context :is_live? do

            it "should be true when today in between start and close" do
                campaign = FactoryGirl.build(:campaign)
                campaign.is_live?.should be_true
            end

            it "should have false when today is before start" do
                start_date = Time.now + 1.day
                campaign = FactoryGirl.build(:campaign, live_date:  start_date)
                campaign.is_live?.should be_false
            end

            it "should have false when today is after close" do
                end_date = Time.now - 1.day
                campaign = FactoryGirl.build(:campaign, close_date: end_date)
                campaign.is_live?.should be_false
            end
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

        context "giver ducktype" do

            let(:object)  { campaign }

            it "should have a name" do
                object.name.class.should == String
            end

            it "should have a photo_url at :get_photo" do
                object.get_photo.class.should == String
            end

            it "should have a unique ID" do
                object.id.class.should == Fixnum
            end

            it "should have a class" do
                object.class.should == Campaign
            end

        end

    end

end