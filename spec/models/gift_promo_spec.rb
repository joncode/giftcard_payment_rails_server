require 'spec_helper'

describe GiftPromo do
    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
    end
    before(:each) do
        Merchant.delete_all
        @provider = FactoryGirl.create(:merchant)
        @gift_hsh = {}
        @gift_hsh["detail"]         = "this is good through 9PM"
        @gift_hsh["message"]        = "here is the promo gift"
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["merchant_id"]    = @provider.id
        @gift_hsh["provider_name"]  = @provider.name
        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    it_should_behave_like "gift serializer" do
        let(:object) { GiftPromo.create(@gift_hsh) }
    end

    it "should create gift" do
        gift_promo = GiftPromo.create(@gift_hsh)
        gift_promo.class.should    == GiftPromo
        gift_promo.detail.should         == "this is good through 9PM"
        gift_promo.message.should        == @gift_hsh["message"]
        gift_promo.receiver_name.should  == "Customer Name"
        gift_promo.receiver_email.should == "customer@gmail.com"
        gift_promo.merchant_id.should    == @provider.id
        gift_promo.provider_name.should  == @provider.name
        gift = Gift.find(gift_promo.id)
        gift.class.should          == Gift
        gift.message.should        == @gift_hsh["message"]
        gift.receiver_name.should  == "Customer Name"
        gift.receiver_email.should == "customer@gmail.com"
        gift.merchant_id.should    == @provider.id
        gift.provider_name.should  == @provider.name
    end

    it "should not run add provider if it has provider ID and name" do
        Gift.any_instance.should_not_receive(:add_merchant_name)
        gift_promo = GiftPromo.create @gift_hsh
    end

    it "should add the provider name to the gift" do
        @gift_hsh.delete("provider_name")
        Gift.any_instance.should_receive(:add_merchant_name)
        gift_promo = GiftPromo.create @gift_hsh
    end

    it "should set the giver info to the BizUser" do
        biz_user = BizUser.find(@provider.id)
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.giver_id.should   == biz_user.id
        gift.giver_name.should == biz_user.name
        gift.giver.should      == biz_user
        gift.giver_type.should == biz_user.class.to_s
    end

    it "should create a Debt for the BizUser and associate" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.owner.should   == @provider.biz_user
        gift.payable.amount.should  == BigDecimal("4.50")
    end

    it "should calculate the correct value from the shoppingCart" do
        @gift_hsh.delete("value")
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.owner.should   == @provider.biz_user
        gift.payable.amount.should  == BigDecimal("4.50")
    end

    it "should set the cost correctly" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.cost.should            == "0"
    end

    it "should set the cat to 200" do
        gift = GiftPromo.create @gift_hsh
        gift.reload
        gift.cat.should           == 200
    end

    it "should set cat to different number if included in params" do
        @gift_hsh["cat"] = 500
        gift        = GiftPromo.create @gift_hsh
        gift.reload
        gift.cat.should == 500
    end


    xit "should set the expiration date" do

    end

    context "messaging" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver", email: "promo_rec@yahoo.com")
            @card     = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
            @provider = FactoryGirl.create(:merchant)
            @biz_user = @provider.biz_user
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_email"] = @receiver.email
            @gift_hsh["merchant_id"]    = @provider.id
            @gift_hsh["giver"]          = @biz_user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["credit_card"]    = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            ResqueSpec.reset!
            WebMock.reset!
        end

        it "should not email invoice to the sender" do
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            response = GiftPromo.create @gift_hsh

            run_delayed_jobs
            abs_gift_id = response.id + NUMBER_ID

            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-gift-receipt"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                else
                    true
                end

            }.once
        end

        it "should email notify the recipient" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            response = GiftPromo.create @gift_hsh
            run_delayed_jobs
            abs_gift_id = response.id + NUMBER_ID
            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-notify-receiver"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                else
                    true
                end
            }.once
        end

        it "should push notify to app-user recipients" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@biz_user.name} sent you a gift!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1,:android =>{:alert => "#{@biz_user.name} sent you a gift!"}}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            response = GiftPromo.create @gift_hsh
            run_delayed_jobs
        end

        # it "should not message users when payment_error" do
        #     stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
        #     stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
        #     good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@biz_user.name} sent you a gift",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
        #     Urbanairship.should_not_receive(:push).with(good_push_hsh)
        #     GiftPromo.create @gift_hsh
        #     run_delayed_jobs
        # end

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
#  merchant_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  pay_type       :string(255)
#  pay_id         :integer
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  merchant_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
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
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

