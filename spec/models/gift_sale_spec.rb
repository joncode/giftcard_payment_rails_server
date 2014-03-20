require 'spec_helper'

describe GiftSale do

    context "Full Tests + with Receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @card     = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
            @provider = FactoryGirl.create(:provider)
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_id"]    = @receiver.id
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["credit_card"]    = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
        end

        it_should_behave_like "gift serializer" do
            let(:gift) { GiftSale.create(@gift_hsh) }
        end

        it "should create a gift" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.receiver.should        == @receiver
            gift.giver.should           == @user
            gift.value.should           == "45"
            gift.cost.should            == (@gift_hsh["value"].to_f * 0.85).to_s
            gift.service.should         == @gift_hsh["service"]
            gift.provider.should        == @provider
            gift.shoppingCart.should    == @gift_hsh["shoppingCart"]
        end

        it "should create a Sale for the total amount" do
            #Sale.with({"card_id"=>1, "number"=>"4417121029961508", "month_year"=>"0217", "first_name"=>"Jimmy", "last_name"=>"Basic", "amount"=>"47.25", "unique_id"=>"Sarah_Receiver_1"})
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.payable.class.should    == Sale
            gift.payable.revenue.should  == BigDecimal("47.25")
            gift.payable.card_id.should  == @card.id
            gift.payable.giver_id.should == @user.id
            gift.credit_card.should      == @card.id.to_s
        end

        it "should set the status of the new gift to 'open'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.status.should  == "open"
        end

        it "should set the pay_stat to 'charge_unpaid'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.pay_stat.should == "charge_unpaid"
        end

        it "should set the cat to 0" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.cat.should     == 0
        end

        it "should not allow regifting to deactivated receivers" do
            @receiver.update(active: false)
            gift        = GiftSale.create @gift_hsh
            gift.should == "User is no longer in the system , please gift to them with phone, email, facebook, or twitter"
        end

        it "should create gift for request bug fix" do
            req = {"giver_id"=>1, "giver_name"=>"Jimmy Basic", "value"=>"100.00", "service"=>"4.00", "receiver_id"=>1, "receiver_name"=>"Someone New", "provider_id"=>1, "credit_card"=>1}
            req["shoppingCart"] = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.giver_name.should == "Jimmy Basic"
        end
    end

    context "without Receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @card     = FactoryGirl.create(:card, user: @user)
            @provider = FactoryGirl.create(:provider)
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = "Jennifer Receiver"
            @gift_hsh["receiver_email"] = "jenny@gmail.com"
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["credit_card"]    = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        end

        it "should create a gift via email" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.receiver_email.should  == @gift_hsh["receiver_email"]
            gift.receiver_id.should     == nil
            gift.giver.should           == @user
            gift.value.should           == "45"
            gift.service.should         == @gift_hsh["service"]
            gift.provider.should        == @provider
        end

        it "should create a gift via facebook_id" do
            @gift_hsh.delete('receiver_email')
            @gift_hsh["facebook_id"] = "6475847342"
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.facebook_id.should     == "6475847342"
            gift.receiver_id.should     == nil
        end

        it "should create a gift via twitter" do
            @gift_hsh.delete('receiver_email')
            @gift_hsh["twitter"] = "6475847342"
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.twitter.should         == "6475847342"
            gift.receiver_id.should     == nil
        end

        it "should create a gift via receiver_phone" do
            @gift_hsh.delete('receiver_email')
            @gift_hsh["receiver_phone"] = "6475847342"
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.receiver_phone.should  == "6475847342"
            gift.receiver_id.should     == nil
        end

        it "should set the status of the new gift to 'incomplete'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.status.should   == "incomplete"
        end

        it "should set the pay_stat to 'charge_unpaid'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.pay_stat.should == "charge_unpaid"
        end

        context "oauth credentials" do

            it "should create a gift with oauth credentials" do
                @gift_hsh.delete('receiver_email')
                hsh =  {"token"=>"9q3562341341", "secret"=>"92384619834", "network"=>"twitter", "network_id"=>"9865465748", "handle"=>"razorback", "photo"=>"cdn.akai.twitter/791823401974.png"}
                @gift_hsh["receiver_oauth"] = hsh
                gift = GiftSale.create @gift_hsh
                gift.reload
                gift.oauth.network_id.should == gift.twitter
                gift.message.should          == @gift_hsh["message"]
                gift.receiver_name.should    == @gift_hsh["receiver_name"]
                gift.oauth.should == Oauth.last
            end

        end
    end

    context "payment error credit card situations" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @card     = FactoryGirl.create(:card, user: @user)
            @provider = FactoryGirl.create(:provider)
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_id"]    = @receiver.id
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})

        end

        it "should return message when credit card is not found" do
            @gift_hsh["credit_card"]    = 1029318723
            response = GiftSale.create @gift_hsh
            response.should == "We do not have that credit card on record.  Please choose a different card."
            #expect { GiftSale.create @gift_hsh }.to raise_error
        end

        it "should handle a duplicate charge attempt [3-11]" do
            Sale.any_instance.stub(:resp_code).and_return(3)
            Sale.any_instance.stub(:reason_code).and_return(11)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should handle an expired credit card [3-8]" do
            Sale.any_instance.stub(:resp_code).and_return(3)
            Sale.any_instance.stub(:reason_code).and_return(8)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-200]" do
            #This error code applies only to merchants on FDC Omaha. The credit card number is invalid.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(200)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-201]" do
            # This error code applies only to merchants on FDC Omaha. The expiration date is invalid.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(201)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-2]" do
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(2)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-210]" do
            # This error code applies only to merchants on FDC Omaha. The merchant type is incorrect.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(210)
            @gift_hsh["credit_card"]    = @card.id
            GiftSale.create @gift_hsh
            gift = Gift.where(credit_card: @card.id.to_s).first
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should return the reason text on :create" do
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(210)
            Sale.any_instance.stub(:reason_text).and_return("This transaction has been declined")
            @gift_hsh["credit_card"]    = @card.id
            response = GiftSale.create @gift_hsh
            response.should == "This transaction has been declined"
        end
    end

    context "messaging" do

        before(:each) do
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})

            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @card     = FactoryGirl.create(:card, name: @user.name, user_id: @user.id)
            @provider = FactoryGirl.create(:provider)
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just Bought a Gift!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_id"]    = @receiver.id
            @gift_hsh["provider_id"]    = @provider.id
            @gift_hsh["giver"]          = @user
            @gift_hsh["value"]          = "45.00"
            @gift_hsh["service"]        = "2.25"
            @gift_hsh["credit_card"]    = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            ResqueSpec.reset!
            WebMock.reset!
        end

        it "should email invoice to the sender" do
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            response = GiftSale.create @gift_hsh

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

            }.twice
        end

        it "should email notify the recipient" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            response = GiftSale.create @gift_hsh
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
            }.twice
        end

        it "should push notify to app-user recipients" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@user.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            response = GiftSale.create @gift_hsh
            run_delayed_jobs
        end

        it "should not message users when payment_error" do
            auth_response = "3,2,33,This transaction has been declined.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@card.first_name},#{@card.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            good_push_hsh = {:aliases =>["#{@receiver.ua_alias}"],:aps =>{:alert => "#{@user.name} sent you a gift at #{@provider.name}!",:badge=>1,:sound=>"pn.wav"},:alert_type=>1}
            Urbanairship.should_not_receive(:push).with(good_push_hsh)
            GiftSale.create @gift_hsh
            run_delayed_jobs
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

