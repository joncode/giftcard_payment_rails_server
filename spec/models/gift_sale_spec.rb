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

        it "should create a gift" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.receiver.should        == @receiver
            gift.giver.should           == @user
            gift.value.should           == @gift_hsh["value"]
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

        it "should set the status of the new gift to 'notified'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.status.should   == "open"
        end

        it "should set the pay_stat to 'charge_unpaid'" do
            gift        = GiftSale.create @gift_hsh
            gift.reload
            gift.pay_stat.should == "charge_unpaid"
        end

        it "should not allow regifting to deactivated receivers" do
            @receiver.update(active: false)
            gift        = GiftSale.create @gift_hsh
            gift.should == "User is no longer in the system , please gift to them with phone, email, facebook, or twitter"
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
            gift.value.should           == @gift_hsh["value"]
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
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should handle an expired credit card [3-8]" do
            Sale.any_instance.stub(:resp_code).and_return(3)
            Sale.any_instance.stub(:reason_code).and_return(8)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-200]" do
            #This error code applies only to merchants on FDC Omaha. The credit card number is invalid.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(200)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-201]" do
            # This error code applies only to merchants on FDC Omaha. The expiration date is invalid.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(201)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-2]" do
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(2)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

        it "should hande a declined card [2-210]" do
            # This error code applies only to merchants on FDC Omaha. The merchant type is incorrect.
            Sale.any_instance.stub(:resp_code).and_return(2)
            Sale.any_instance.stub(:reason_code).and_return(210)
            @gift_hsh["credit_card"]    = @card.id
            gift = GiftSale.create @gift_hsh
            gift.status.should   == "cancel"
            gift.pay_stat.should == "payment_error"
        end

    end

    context "messaging" do

        xit "should email invoice to the sender" do
            run_delayed_jobs
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
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

        xit "should email notify the recipient" do
            run_delayed_jobs
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
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

        xit "should push notify to app-user recipients" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
        end

        xit "should not message users when payment_error" do

        end

    end
end