require 'spec_helper'

describe AppController do

    describe "#create_gift" do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
        end

        it "should find user account for old email" do
            # take a user , add an email
            @user.update_attribute(:email, "second@gmail.com")
            # then we hit create gift
            # with receiver email = old email
            gift = FactoryGirl.create :gift, { receiver_email: "neil@gmail.com" }
            cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
            post :create_gift, format: :json, gift: set_gift_as_sent(gift) , shoppingCart: cart , token: @user.remember_token
            new_gift = Gift.find(json["success"]["Gift_id"])
            new_gift.receiver_id.should == @user.id
        end

        # Git should valide total and service
    end

    def set_gift_as_sent gift
        {
            receiver_email: gift.receiver_email,
            total: gift.total,
            service: gift.service,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.to_json
    end

end