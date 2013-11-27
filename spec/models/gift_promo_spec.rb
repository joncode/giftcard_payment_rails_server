require 'spec_helper'

describe GiftPromo do

    before(:each) do
        Provider.delete_all
        @provider = FactoryGirl.create(:provider)
        @gift_hsh = {}
        @gift_hsh["message"]        = "here is the promo gift"
        @gift_hsh["receiver_name"]  = "Customer Name"
        @gift_hsh["receiver_email"] = "customer@gmail.com"
        @gift_hsh["provider_id"]    = @provider.id
        @gift_hsh["provider_name"]  = @provider.name
        @gift_hsh["value"]          = "100.00"
        @gift_hsh["shoppingCart"]   = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
    end

    it "should create gift" do

        gift_promo = GiftPromo.create(@gift_hsh)
        gift_promo.class.should    == GiftPromo
        gift_promo.message.should        == @gift_hsh["message"]
        gift_promo.receiver_name.should  == "Customer Name"
        gift_promo.receiver_email.should == "customer@gmail.com"
        gift_promo.provider_id.should    == @provider.id
        gift_promo.provider_name.should  == @provider.name
        gift = Gift.find(gift_promo.id)
        gift.class.should          == Gift
        gift.message.should        == @gift_hsh["message"]
        gift.receiver_name.should  == "Customer Name"
        gift.receiver_email.should == "customer@gmail.com"
        gift.provider_id.should    == @provider.id
        gift.provider_name.should  == @provider.name
    end

    it "should not run add provider if it has provider ID and name" do
        Gift.any_instance.should_not_receive(:add_provider_name)
        gift_promo = GiftPromo.create @gift_hsh
    end

    it "should add the provider name to the gift" do
        @gift_hsh.delete("provider_name")
        Gift.any_instance.should_receive(:add_provider_name)
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
        gift.value.should           == "100.00"
        gift.payable.owner.should   == @provider.biz_user
        gift.payable.amount.should  == BigDecimal("15.00")
    end

end