require 'spec_helper'

describe AppController do

    describe "#create_gift" do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
        end

        {
            email: "jon@gmail.com",
            phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }.stringify_keys.each do |type_of, identifier|
            it "should find user account for old #{type_of}" do
                # take a user , add an email
                @user.update_attribute(type_of, identifier)
                # then we hit create gift
                # with receiver email = old email
                if (type_of == "phone") || (type_of == "email")
                    key = "receiver_#{type_of}"
                else
                    key = type_of
                end
                gift = FactoryGirl.create :gift, { key => identifier}
                cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
                post :create_gift, format: :json, gift: set_gift_as_sent(gift, key) , shoppingCart: cart , token: @user.remember_token
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end
        end

        # Git should valide total and service
    end

    def set_gift_as_sent gift, key
        {
            key => gift.send(key),
            total: gift.total,
            service: gift.service,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.to_json
    end

end