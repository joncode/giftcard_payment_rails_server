require 'spec_helper'

describe GiftRegift do

    context "With Receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            @old_gift  = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
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
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should       == @gift_hsh["message"]
            gift.receiver_name.should == @receiver.name
            gift.receiver.should      == @receiver
            gift.provider.should      == @old_gift.provider
        end

        it "should make the old gift receiver the new gift giver" do
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
            gift.giver.should         == @regifter
            gift.giver_name.should    == @regifter.name
        end

        it "should not transfer the old message if not message" do
            @gift_hsh.delete('message')
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
        end

        it "should not run add provider" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            gift_regift = GiftRegift.create @gift_hsh
        end

        it "should transfer old gift value to new gift" do
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.value.should   == "201.00"
            gift.service.should == nil
        end
    end

    context "without receiver ID" do

        before(:each) do
            @user     = FactoryGirl.create(:user)
            @regifter = FactoryGirl.create(:user, first_name: "Jon", last_name: "Regifter")
            @old_gift  = FactoryGirl.create(:gift, giver: @user, receiver: @regifter, message: "DO NOT REGIFT!", value: "201.00", service: '10.05')
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
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
            gift.giver.should         == @regifter
            gift.giver_name.should    == @regifter.name
        end

        it "should not transfer the old message if not message" do
            @gift_hsh.delete('message')
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.message.should_not   == "DO NOT REGIFT!"
        end

        it "should not run add provider" do
            Gift.any_instance.should_not_receive(:add_provider_name)
            gift_regift = GiftRegift.create @gift_hsh
        end

        it "should transfer old gift value to new gift" do
            gift = GiftRegift.create @gift_hsh
            gift.reload
            gift.value.should == "201.00"
            gift.service.should == nil
        end
    end


end