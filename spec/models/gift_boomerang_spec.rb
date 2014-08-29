require 'spec_helper'

describe GiftBoomerang do

    before(:each) do
        boom = FactoryGirl.create(:boomerang)
        @user     = FactoryGirl.create(:user)
        @receiver = FactoryGirl.create(:user)
        @old_gift = FactoryGirl.create(:gift, giver: @user, receiver_phone: "2152667474", receiver_name: "No Existo", receiver_id: @receiver.id, message: "Hey Join this app!", value: "201.00", cost: "187.3", service: '10.05', cat: 300)
        @gift_hsh = {}
        @gift_hsh["old_gift_id"]   = @old_gift.id
    end

    context "Validations" do


        it_should_behave_like "gift serializer" do
            let(:object) { GiftBoomerang.create(@gift_hsh) }
        end

        it_should_behave_like "gift status" do
            let(:object) { GiftBoomerang.create(@gift_hsh) }
            let(:cat)    { 307 }
        end

        it "should correctly transfer value/cost/service including decimals" do
            gift        = GiftBoomerang.create @gift_hsh
            gift.should be_valid
            gift.value.should        == "201"
            gift.cost.should         == "187.30"
            gift.shoppingCart.should == @old_gift.shoppingCart
            gift.service.should      == "10.05"
        end

        it "should create gift with old_gift provider" do
            gift        = GiftBoomerang.create @gift_hsh
            gift.reload
            gift.message.should       == "Here is the gift you sent to 215-266-7474. They never created an account, so we’re returning this gift to you. Use Regift to try your friend again, send it to a new friend, or use the gift yourself!"
            gift.receiver_name.should == @user.name
            gift.receiver.should      == @user
            gift.provider.should      == @old_gift.provider
            gift.provider_name.should == @old_gift.provider_name
        end

        it "should make the old gift receiver the new gift giver" do
            gift        = GiftBoomerang.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
            gift.giver_name.should    == "Boomerang"
            gift.giver.class.should   == Boomerang
        end

        it "should add the boomerang message" do
            @gift_hsh.delete('message')
            gift        = GiftBoomerang.create @gift_hsh
            gift.reload
            gift.message.should == "Here is the gift you sent to 215-266-7474. They never created an account, so we’re returning this gift to you. Use Regift to try your friend again, send it to a new friend, or use the gift yourself!"
        end

        it "should not run add provider" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            gift_regift = GiftBoomerang.create @gift_hsh
        end

        it "should set cat for regift of GiftSale to 350" do
            gift        = GiftBoomerang.create @gift_hsh
            gift.reload
            gift.cat.should      == 307
        end

        it "should set the status of the new gift to 'open'" do
            gift        = GiftBoomerang.create @gift_hsh
            gift.reload
            gift.status.should   == "open"
        end

        it "should not allow regifting to deactivated receivers" do
            @user.update(active: false)
            gift        = GiftBoomerang.create @gift_hsh
            gift.should == "Boomerang does not gift to non-active users"
        end
    end

    context "status behavior" do
        # before(:each) do
        #     @user     = FactoryGirl.create(:user)
        #     @old_gift = FactoryGirl.create(:gift, giver: @user, receiver_phone: "2152667474", receiver_name: "No Existo", message: "Hey Join this app!", value: "201.00", cost: "187.3", service: '10.05', cat: 300)
        #     @gift_hsh = {}
        #     @gift_hsh["old_gift_id"]   = @old_gift.id
        # end

        it "should set the parent gift as the payable" do
            @old_gift.update(pay_stat: "refund_comp")
            gift        = GiftBoomerang.create @gift_hsh
            gift.payable.should         == @old_gift
            gift.payable_type.should    == "Gift"
            gift.payable_id.should      == @old_gift.id
            gift.pay_stat.should == "refund_comp"
        end

        it "should set the status of the parent gift to regifted" do
            @old_gift.update(pay_stat: "charge_unpaid_settled")
            gift        = GiftBoomerang.create @gift_hsh
            @old_gift.reload
            @old_gift.status.should   == "regifted"
            @old_gift.pay_stat.should == "charge_regifted"
        end
    end

    context "messaging" do

        before(:each) do
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            ResqueSpec.reset!
            WebMock.reset!
        end

        it "should NOT email invoice to the sender" do
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            response = GiftBoomerang.create @gift_hsh

            run_delayed_jobs
            abs_gift_id = response.id + NUMBER_ID

            WebMock.should have_requested(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").with { |req|
                puts req.body;
                b = JSON.parse(req.body);
                if b["template_name"] == "iom-gift-gift-receipt"
                    link = b["message"]["merge_vars"].first["vars"].first["content"];
                    link.match(/signup\/acceptgift\?id=#{abs_gift_id}/)
                    false
                else
                    true
                end

            }.once
        end

        it "should email notify the recipient" do
            stub_request(:post, "https://q_NVI6G1RRaOU49kKTOZMQ:Lugw6dSXT6-e5mruDtO14g@go.urbanairship.com/api/push/").to_return(:status => 200, :body => "", :headers => {})
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})

            response = GiftBoomerang.create @gift_hsh
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
            auth_response = "1,1,1,This transaction has been approved.,JVT36N,Y,2202633834,,,47.25,CC,auth_capture,,#{@user.first_name},#{@user.last_name},,,,,,,,,,,,,,,,,"
            stub_request(:post, "https://test.authorize.net/gateway/transact.dll").to_return(:status => 200, :body => auth_response, :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            good_push_hsh = {:aliases =>["#{@user.ua_alias}"],:aps =>{:alert => "Boomerang! We are returning this gift to you because your friend never created an account",:badge=>1,:sound=>"pn.wav"},:alert_type=>1,:android =>{:alert => "Boomerang! We are returning this gift to you because your friend never created an account"}}
            Urbanairship.should_receive(:push).with(good_push_hsh)
            response = GiftBoomerang.create @gift_hsh
            run_delayed_jobs
        end

    end

end
