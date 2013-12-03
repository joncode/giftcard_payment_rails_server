require 'spec_helper'

describe GiftRegift do

    context "With Receiver ID" do

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

        it "should create gift" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should       == @gift_hsh["message"]
            gift.receiver_name.should == @receiver.name
            gift.receiver.should      == @receiver
            gift.provider.should      == @old_gift.provider
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

        it "should not run add provider" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            gift_regift = GiftRegift.create @gift_hsh
        end

        it "should transfer old gift value to new gift" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.value.should   == "201.00"
            gift.service.should == nil
        end
    end

    context "without receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @old_gift = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
            @gift_hsh = {}
            @gift_hsh["message"]        = "I just REGIFTED!"
            @gift_hsh["receiver_name"]  = "Weatherby Rochester"
            @gift_hsh["receiver_email"] = "weatherby.rochester@gmail.com"
            @gift_hsh["giver"]          = @regifter
            @gift_hsh["old_gift_id"]    = @old_gift.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            @gift_hsh
        end

        it "should create gift" do
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should       == @gift_hsh["message"]
            gift.receiver_name.should == @gift_hsh["receiver_name"]
            gift.receiver_email.should == @gift_hsh["receiver_email"]
            gift.receiver_id.should   == nil
            gift.provider.should      == @old_gift.provider
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

        it "should not run add provider" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            gift_regift = GiftRegift.create @gift_hsh
        end

        it "should transfer old gift value to new gift" do
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.value.should   == "201.00"
            gift.service.should == nil
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
            @old_gift.update(pay_stat: "refund_comp_comp")
            gift        = GiftRegift.create @gift_hsh
            gift.reload
            gift.pay_stat.should == "refund_comp_comp"
        end

        it "should reject promo gift regifting" do
            debt        = FactoryGirl.create(:debt)
            biz_user    = FactoryGirl.create(:provider).biz_user
            promo       = FactoryGirl.create(:gift, payable_type: "Debt", giver_type: "BizUser", payable_id: debt.id, giver_id: biz_user.id )
            @gift_hsh["old_gift_id"] = promo.id
            resp        = GiftRegift.create @gift_hsh
            puts "#{resp.inspect} == RESP"
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
            @old_gift.status.should   == "complete_regifted_nil"
            @old_gift.pay_stat.should == "charge_regifted_regifted"
        end

        it "should not regift when old gift cannot be found" do
            @gift_hsh["old_gift_id"] = 123123
            expect { GiftRegift.create(@gift_hsh) }.to raise_error
        end

    end


end