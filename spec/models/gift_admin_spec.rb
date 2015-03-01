require 'spec_helper'

describe GiftAdmin do
    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
    end
    before(:each) do
        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
        @admin    = FactoryGirl.create(:admin_user)
        @giver    = @admin.giver
        @gift_hsh = {}
        @gift_hsh["giver"]          = @giver
        @gift_hsh["message"]        = "here is the admin gift"
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["provider_id"]    = @provider.id
        @gift_hsh["provider_name"]  = @provider.name
        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    it_should_behave_like "gift serializer" do
        let(:object) { GiftAdmin.create(@gift_hsh) }
    end

    it_should_behave_like "gift status" do
        let(:object) { GiftAdmin.create(@gift_hsh) }
        let(:cat)    { 100 }
    end

    it "should create gift" do

        gift_admin = GiftAdmin.create(@gift_hsh)
        gift_admin.class.should    == GiftAdmin
        gift_admin.message.should        == @gift_hsh["message"]
        gift_admin.receiver_name.should  == "Customer Name"
        gift_admin.receiver_email.should == "customer@gmail.com"
        gift_admin.provider_id.should    == @provider.id
        gift_admin.provider_name.should  == @provider.name
        gift = Gift.find(gift_admin.id)
        gift.class.should          == Gift
        gift.message.should        == @gift_hsh["message"]
        gift.receiver_name.should  == "Customer Name"
        gift.receiver_email.should == "customer@gmail.com"
        gift.provider_id.should    == @provider.id
        gift.provider_name.should  == @provider.name
    end

    it "should set the giver to 'ItsOnMe Staff' giver" do
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.giver_id.should   == @admin.id
        gift.giver_name.should == @giver.name
        gift.giver.should      == @giver
        gift.giver_type.should == @giver.class.to_s
    end

    it "should create a Debt for the AdminUser and associate" do
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.owner.should   == @giver
        gift.payable.amount.should  == BigDecimal("30")
    end

    it "should calculate the correct value from the shoppingCart" do
        @gift_hsh.delete("value")
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.value.should           == "30"
        gift.payable.amount.should  == BigDecimal("30")
    end

    it "should set the price correctly" do
        @gift_hsh["shoppingCart"] = [{"price"=>"4", "price_promo"=>"1.23", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.value.should           == "8"
    end

    it "should set the cost based of the promo prices correctly" do
        @gift_hsh["shoppingCart"] = [{"price"=>"4", "price_promo"=>"1.23", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.cost.should            == "2.46"
    end

    it "should set the cost at 85% of price if promo prices is missing" do
        @gift_hsh["shoppingCart"] = [{"price"=>"4", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.cost.should            == "6.80"
    end

    it "should set the cat to 100" do
        @gift_hsh["shoppingCart"] = [{"price"=>"4", "price_promo"=>"1.23", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json
        gift = GiftAdmin.create @gift_hsh
        gift.reload
        gift.cat.should            == 100
    end

    it "should set cat to different number if included in params" do
        @gift_hsh["shoppingCart"] = [{"price"=>"4", "price_promo"=>"1.23", "quantity"=>2, "section"=>"Beer", "item_id"=>543, "item_name"=>"Corona"}].to_json
        @gift_hsh["cat"] = 500
        gift        = GiftAdmin.create @gift_hsh
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
            @provider = FactoryGirl.create(:provider)
            @admin_user = FactoryGirl.create(:admin_user)
            @giver    = @admin_user.giver
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_email"] = @receiver.email
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @giver
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
            response = GiftAdmin.create @gift_hsh

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

            response = GiftAdmin.create @gift_hsh
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
            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@giver.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1, :android =>{:alert => "#{@giver.name} sent you a gift at #{@provider.name}!"}}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            response = GiftAdmin.create @gift_hsh
            run_delayed_jobs
        end

        # it "should not message users when payment_error" do
        #     stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
        #     stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
        #     good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@giver.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
        #     Urbanairship.should_not_receive(:push).with(good_push_hsh)
        #     GiftAdmin.create @gift_hsh
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
#  provider_id    :integer
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
#  provider_id    :integer
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
#

