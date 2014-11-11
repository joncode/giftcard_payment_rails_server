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


            context "Campaign Live Status" do
                context "Campaign is live" do
                    before do
                        @today = Time.now.utc
                        @campaign = FactoryGirl.create :campaign, live_date: 1.week.ago, close_date: @today + 1.week
                    end
                    it "should be live if item has reserve, and expires in the future" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 1, expires_at: (@today + 1.week))
                        cam_item.live?.should be_true
                    end
                    it "should NOT be live if item has reserve, and expires in the past" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                    it "should NOT be live if item has no reserve and expires in the future" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                    it "should NOT be live if item has no reserve and expires in the past" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                end
                context "Campaign is NOT live" do
                    before do
                        @today = Time.now.utc
                        @campaign = FactoryGirl.create :campaign, live_date: 1.week.ago, close_date: @today - 1.week
                    end
                    it "should NOT be live if item has reserve, and expires in the future" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 1, expires_at: (@today + 1.week))
                        cam_item.live?.should be_false
                    end
                    it "should NOT be live if item has reserve, and expires in the past" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                    it "should NOT be live if item has no reserve and expires in the future" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                    it "should NOT be live if item has no reserve and expires in the past" do
                        cam_item = FactoryGirl.create(:campaign_item, campaign_id: @campaign.id, reserve: 0, expires_at: 1.week.ago)
                        cam_item.live?.should be_false
                    end
                end
            end
        end

        context "sms messages" do

            it "should respond with human readable status_text" do
                campaign = FactoryGirl.create(:campaign)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 0, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.cname} - textword (#{cam_item.textword}) reserve is empty"
                cam_item.update(reserve: 1)
                cam_item.status_text.should == "#{campaign.cname} - textword (#{cam_item.textword}) is live"
                start_date = Time.now.utc + 1.day
                campaign = FactoryGirl.create(:campaign, live_date:  start_date)
                cam_item = FactoryGirl.create(:campaign_item, reserve: 1, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.cname} - textword (#{cam_item.textword}) has not started yet"
                end_date = Time.now.utc - 1.day
                campaign = FactoryGirl.create(:campaign, close_date: end_date)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id, expires_at: (Time.now + 1.month))
                cam_item.status_text.should == "#{campaign.cname} - textword (#{cam_item.textword}) is closed"
            end

            it "should respond with 'is closed' when today is the close date BUG FIX" do
                campaign = FactoryGirl.create(:campaign, close_date: Time.now.utc)
                cam_item = FactoryGirl.create(:campaign_item, campaign_id: campaign.id)

                cam_item.status_text.should == "#{campaign.cname} - textword (#{cam_item.textword}) is closed"
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

        context "live status" do
            it "has reserve, campaign is live, and expires_at in future" do
                today = Time.now
                c = FactoryGirl.create :campaign, live_date: 1.week.ago, close_date: today + 1.week
                ci = FactoryGirl.create :campaign_item, budget: 100, reserve: 100, campaign_id: c.id, expires_at: today + 1.week
                ci.live?.should == true
            end
            it "has reserve, campaign is live, and expires_at is nil and expires_in is positive" do
                today = Time.now
                c = FactoryGirl.create :campaign, live_date: 1.week.ago, close_date: today + 1.week
                ci = FactoryGirl.create :campaign_item, budget: 100, reserve: 100, campaign_id: c.id, expires_at: nil, expires_in: 10
                ci.live?.should == true
            end
        end
    end

end