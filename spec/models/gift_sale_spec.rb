require 'spec_helper'

describe GiftSale do

    context "With Receiver ID" do

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
            @gift_hsh["card_id"]        = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            @gift_hsh
        end

        it "should create a gift" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.message.should         == @gift_hsh["message"]
            gift.receiver_name.should   == @gift_hsh["receiver_name"]
            gift.receiver_id.should     == @gift_hsh["receiver_id"]
            gift.receiver.should        == @receiver
            gift.giver.should           == @user
            gift.value.should           == @gift_hsh["value"]
            gift.service.should         == @gift_hsh["service"]
            gift.provider.should        == @provider
        end

        it "should create a Sale for the total amount" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.payable.class.should    == Sale
            gift.payable.revenue.should  == BigDecimal("47.25")
            gift.payable.card_id.should  == @card.id
            gift.payable.giver_id.should == @user.id
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
            @gift_hsh["card_id"]        = @card.id
            @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            @gift_hsh
        end

        it "should create a gift" do
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

        it "should create a Sale for the total revenue" do
            gift = GiftSale.create @gift_hsh
            gift.reload
            gift.payable.class.should    == Sale
            gift.payable.revenue.should  == BigDecimal("47.25")
            gift.payable.card_id.should  == @card.id
            gift.payable.giver_id.should == @user.id
        end

    end

    context "status behavoir" do

        it "should set the pay stat to charge_unpaid" do

        end

        

    end


end