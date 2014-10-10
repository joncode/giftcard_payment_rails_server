require 'spec_helper'

describe CampaignItem do

    context "associations and validations" do

        context "gift_campaign messages" do

            it "should reply if there is reserve left" do
                cam_item = FactoryGirl.create(:campaign_item, reserve: 1)
                cam_item.has_reserve?.should be_true
                cam_item = FactoryGirl.create(:campaign_item, reserve: 0)
                cam_item.has_reserve?.should be_false
            end

            it "should combine date checks with reserve to :live?" do
                campaign = FactoryGirl.create(:campaign)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 1, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.live?.should be_true
                cam_item = FactoryGirl.create(:campaign_item, reserve: 0, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.live?.should be_false
                start_date = Time.now.utc + 1.day
                campaign = FactoryGirl.create(:campaign, live_date:  start_date)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.live?.should be_false
                end_date = Time.now.utc - 1.day
                campaign = FactoryGirl.create(:campaign, close_date: end_date)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.live?.should be_false
                campaign = FactoryGirl.create(:campaign)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 1, campaign_id: campaign.id)
                cam_item.live?.should be_false
            end
        end

        context "sms messages" do

            it "should respond with human readable status_text" do
                campaign = FactoryGirl.create(:campaign)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 0, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.name} #{cam_item.textword} reserve is empty"
                cam_item.update(reserve: 1)
                cam_item.status_text.should == "#{campaign.name} #{cam_item.textword} is live"
                start_date = Time.now.utc + 1.day
                campaign = FactoryGirl.create(:campaign, live_date:  start_date)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 1, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.name} #{cam_item.textword} has not started yet"
                end_date = Time.now.utc - 1.day
                campaign = FactoryGirl.create(:campaign, close_date: end_date)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.name} #{cam_item.textword} is closed"
            end

            it "should respond with 'is closed' when today is the close date BUG FIX" do
                campaign = FactoryGirl.create(:campaign, close_date: Time.now.utc)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id)

                cam_item.status_text.should == "#{campaign.name} #{cam_item.textword} is closed"
            end

        end

        it "should belongs_to a campaign" do
            campaign = FactoryGirl.create(:campaign)
            cam_item = FactoryGirl.create(:campaign_item, campaign: campaign)
            cam_item.campaign.id.should == campaign.id
            cam_item.campaign_id.should == campaign.id
        end

        it "should belongs_to a provider" do
            p = FactoryGirl.create(:provider)
            cam_item = FactoryGirl.create( :campaign_item, provider_id: p.id)
            cam_item.provider.should == p
        end

        it "should have a shoppingCart" do
            cam_item = FactoryGirl.build :campaign_item
            cam_item.respond_to?(:shoppingCart).should be_true
            cam_item.shoppingCart.should_not be_nil
        end

        it "should build from factory" do
            cam_item = FactoryGirl.build :campaign_item
            cam_item.should be_valid
        end
    end

end