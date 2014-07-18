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
                                                           expire_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @provider.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                detail: "This gift is good until midnight.",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"1\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                budget: 100,
                                                                value: "30",
                                                                cost: "3")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it_should_behave_like "gift serializer" do
            let(:object) { GiftCampaign.create(@gift_hsh) }
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
            gift_campaign.cat.should            == 150
            gift_campaign.cost.should           == "3"
        end

        it "should associate the CampaignItem as the payable" do
            gift_campaign                   = GiftCampaign.create @gift_hsh
            payable                         = gift_campaign.payable
            payable.class.name.should       == "CampaignItem"
            payable.owner.class.name.should == "Campaign"
            payable.success?.should         == true
            payable.resp_code.should        == 1
            payable.reason_text.should      == "Transaction approved."
            payable.reason_code.should      == 1
        end

        it "should correctly set expiration date from expires_at" do
            gift_campaign = GiftCampaign.create @gift_hsh
            gift_campaign.expires_at.should == @expiration.beginning_of_day.in_time_zone
        end

        it "should set admin campaign gift cat to 150" do
            gift_campaign = GiftCampaign.create @gift_hsh
            gift_campaign.cat.should == 150
        end

        it "should set merchant campaign gift cat to 250" do
            @campaign.update(purchaser_type: "BizUser", purchaser_id: @provider.id)
            gift_campaign = GiftCampaign.create @gift_hsh
            gift_campaign.cat.should == 250
        end

        it "should correctly set expiration date from expires_in" do
            @campaign_item.update(expires_in: 30, expires_at: nil)
            gift_campaign                         = GiftCampaign.create @gift_hsh
            gift_campaign.expires_at.round.should == (@campaign_item.created_at.to_date + 30.days)

            @campaign_item.update(expires_in: 30)
            gift_campaign                         = GiftCampaign.create @gift_hsh
            gift_campaign.expires_at.round.should == (@campaign_item.created_at.to_date + 30.days)
        end

        it "should correctly set campaign expire_date from expires_at" do
            gift_campaign = GiftCampaign.create @gift_hsh
            gift_campaign.giver.expire_date.should == @expiration
        end

        it "should correctly decrement campaign item reserve" do
            gift_campaign = GiftCampaign.create @gift_hsh
            gift_campaign.payable.reserve.should == 99
        end

        it "should not decrement campaign item reserve if gift save fails" do
            @gift_hsh.delete('receiver_email')
            gift_campaign = GiftCampaign.create(@gift_hsh)
            gift_campaign.payable.reserve.should == 100
        end

        it "should not create gift if there is no reserve" do
            @campaign_item.update(reserve: 0)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should            == 1
            gift.errors.full_messages[0].should == "Campaign item reserve is empty. No more gifts can be created under this campaign item."
        end

        it "should not create gift if the campaign is not yet live" do
            @campaign.update(live_date: (Time.now.utc + 1.day).to_date)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should == 1
            gift.errors.full_messages[0].should == "Campaign ItsOnMe Promotional Staff 11111 has not started yet. No gifts can be created."
        end

        it "should not create gift if the campaign is closed" do
            @campaign.update(close_date: (Time.now.utc - 1.day).to_date)
            gift = GiftCampaign.create @gift_hsh
            gift.errors.count.should == 1
            gift.errors.full_messages[0].should == "Campaign ItsOnMe Promotional Staff 11111 is closed. No gifts can be created."
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
                                                           expire_date: (Time.now + 1.week).to_date,
                                                           budget: 100)
            @campaign_item = FactoryGirl.create(:campaign_item, provider_id: @location.id,
                                                                campaign_id: @campaign.id,
                                                                message: "Enjoy this special gift on us!",
                                                                expires_at: @expiration,
                                                                shoppingCart: "[{\"price\":\"10\",\"price_promo\":\"8\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]",
                                                                value: "30",
                                                                budget: 100,
                                                                cost:  "0")
            @gift_hsh = {}
            @gift_hsh["receiver_name"]  = "Customer Name"
            @gift_hsh["receiver_email"] = "customer@gmail.com"
            @gift_hsh["payable_id"]     = @campaign_item.id
        end

        it_should_behave_like "gift serializer" do
            let(:object) { GiftCampaign.create(@gift_hsh) }
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
            gift_campaign.cat.should            == 250
            gift_campaign.cost.should           == "0"
        end

        it "should associate the CampaignItem as the payable" do
            gift                            = GiftCampaign.create @gift_hsh
            payable                         = gift.payable
            payable.class.name.should       == "CampaignItem"
            payable.owner.class.name.should == "Campaign"
            payable.success?.should         == true
            payable.resp_code.should        == 1
            payable.reason_text.should      == "Transaction approved."
            payable.reason_code.should      == 1
        end

        context "messaging" do

            before(:each) do
                ResqueSpec.reset!
                WebMock.reset!
            end

            it "should not email invoice to the sender" do
                stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
                stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
                stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
                response = GiftCampaign.create @gift_hsh

                run_delayed_jobs
                abs_gift_id = response.id + NUMBER_ID

                WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                    puts req.body;
                    b = JSON.parse(req.body);
                    if b["template_name"] == "iom-gift-gift-receipt"
                        link = b["message"]["merge_vars"].first["vars"].first["content"];
                        link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                    else
                        true
                    end

                }.once
            end

            it "should email notify the recipient" do
                stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
                stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
                stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

                response = GiftCampaign.create @gift_hsh
                run_delayed_jobs
                abs_gift_id = response.id + NUMBER_ID
                WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                    puts req.body;
                    b = JSON.parse(req.body);
                    if b["template_name"] == "iom-gift-notify-receiver"
                        link = b["message"]["merge_vars"].first["vars"].first["content"];
                        link.match(/signup\/acceptgift\/#{abs_gift_id}/)
                    else
                        true
                    end
                }.once
            end

            it "should push notify to app-user recipients" do
                @receiver = FactoryGirl.create(:user, email: "customer@gmail.com")
                stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
                stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
                stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
                good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@campaign.name} sent you a gift at #{@location.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1,:android =>{:alert => "#{@campaign.name} sent you a gift at #{@location.name}!"}}
                Urbanairship.should_receive(:push).with(good_push_hsh)
                response = GiftCampaign.create @gift_hsh
                run_delayed_jobs
            end

            # it "should not message users when payment_error" do
            #     @receiver = FactoryGirl.create(:user, email: "customer@gmail.com")
            #     stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            #     stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            #     good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@campaign.name} sent you a gift at #{@location.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            #     Urbanairship.should_not_receive(:push).with(good_push_hsh)
            #     GiftCampaign.create @gift_hsh
            #     run_delayed_jobs
            # end
        end
    end
end# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#

