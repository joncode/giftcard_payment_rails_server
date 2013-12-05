require 'spec_helper'

describe GiftRegift do

    context "Full Tests + With Receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @old_gift = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
            @gift_hsh = {}
            @gift_hsh["message"]       = "I just REGIFTED!"
            @gift_hsh["name"]          = @receiver.name
            @gift_hsh["receiver_id"]   = @receiver.id
            @gift_hsh["giver"]         = @regifter
            @gift_hsh["old_gift_id"]   = @old_gift.id
            @gift_hsh
        end

        it "should create gift with old_gift provider" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should       == "I just REGIFTED!"
            gift.receiver_name.should == @receiver.name
            gift.receiver.should      == @receiver
            gift.provider.should      == @old_gift.provider
            gift.provider_name.should == @old_gift.provider_name
        end

        it "should make the old gift receiver the new gift giver" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
            gift.giver.should         == @regifter
            gift.giver_name.should    == @regifter.name
        end

        it "should not transfer the old message if not message" do
            @gift_hsh.delete('message')
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
        end

        it "should not run add provider or regifted" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            Gift.any_instance.should_not_receive(:regifted)
            gift_regift = GiftRegift.create @gift_hsh
        end

        it "should transfer old gift :value, :shoppingCart" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload

            gift.value.should        == "201.00"
            gift.shoppingCart.should == @old_gift.shoppingCart
            gift.service.should      == nil
        end

        it "should set the status of the new gift to 'notified'" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.status.should   == "open"
        end

        it "should not allow regifting to deactivated receivers" do
            @receiver.update(active: false)
            gift        = GiftRegift.create @gift_hsh
            gift.should == "User is no longer in the system , please gift to them with phone, email, facebook, or twitter"
        end
    end

    context "without receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @old_gift = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just REGIFTED!"
            @gift_hsh["name"]           = "Weatherby Rochester"
            @gift_hsh["email"]          = "weatherby.rochester@gmail.com"
            @gift_hsh["giver"]          = @regifter
            @gift_hsh["old_gift_id"]    = @old_gift.id
            @gift_hsh
        end

        it "should create gift with phone" do
            @gift_hsh.delete('email')
            @gift_hsh["phone"] = "6757846764"
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.receiver_name.should  == "Weatherby Rochester"
            gift.receiver_phone.should == "6757846764"
            gift.receiver_id.should    == nil
        end

        it "should create gift with facebook_id" do
            @gift_hsh["facebook_id"] = "675784asd6764"
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.receiver_name.should  == "Weatherby Rochester"
            gift.facebook_id.should    == "675784asd6764"
            gift.receiver_id.should    == nil
        end

        it "should create gift with twitter" do
            @gift_hsh["twitter"] = "345987tery"
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.receiver_name.should  == "Weatherby Rochester"
            gift.twitter.should        == "345987tery"
            gift.receiver_email.should == "weatherby.rochester@gmail.com"
            gift.receiver_id.should    == nil
        end

        it "should create gift with email" do
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should       == @gift_hsh["message"]
            gift.receiver_name.should == "Weatherby Rochester"
            gift.receiver_email.should == "weatherby.rochester@gmail.com"
            gift.receiver_id.should   == nil
            gift.provider.should      == @old_gift.provider
        end

        it "should set the status of the new gift to 'incomplete'" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.status.should   == "incomplete"
        end
    end

    context "status behavior" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @old_gift = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just REGIFTED!"
            @gift_hsh["receiver_name"]  = @receiver.name
            @gift_hsh["receiver_id"]    = @receiver.id
            @gift_hsh["giver"]          = @regifter
            @gift_hsh["old_gift_id"]    = @old_gift.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            @gift_hsh
        end

        it "should take the pay stat of the parent gift" do
            @old_gift.update(pay_stat: "refund_comp")
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.pay_stat.should == "refund_comp"
        end

        it "should reject promo gift regifting" do
            debt        = FactoryGirl.create(:debt)
            biz_user    = FactoryGirl.create(:provider).biz_user
            promo       = FactoryGirl.create(:gift, payable_type: "Debt", giver_type: "BizUser", payable_id: debt.id, giver_id: biz_user.id )
            @gift_hsh["old_gift_id"] = promo.id
            resp        = GiftRegift.create @gift_hsh
            resp.should == "You cannot regift a promotional gift"
        end

        it "should set the parent gift as the payable" do
            @old_gift.update(pay_stat: "refund_comp_comp")
            gift        = GiftRegift.create @gift_hsh
            gift.payable.should         == @old_gift
            gift.payable_type.should    == "Gift"
            gift.payable_id.should      == @old_gift.id
        end

        it "should set the status of the parent gift to regifted" do
            @old_gift.update(pay_stat: "charge_unpaid_settled")
            gift        = GiftRegift.create @gift_hsh
            @old_gift.reload
            @old_gift.status.should   == "regifted"
            @old_gift.pay_stat.should == "charge_regifted"
        end

        it "should not regift when old gift cannot be found" do
            @gift_hsh["old_gift_id"] = 123123
            expect { GiftRegift.create(@gift_hsh) }.to raise_error
        end

    end

    context "messaging" do

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

    end

end