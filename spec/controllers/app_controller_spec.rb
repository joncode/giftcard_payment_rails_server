require 'spec_helper'

describe AppController do

    describe "#create_gift" do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
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
                post :create_gift, format: :json, gift: set_gift_as_sent(gift, key) , shoppingCart: @cart , token: @user.remember_token
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru multiple unique ids for a user object with #{type_of}" do
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids
                gift = FactoryGirl.create :gift, gift_social_id_hsh
                post :create_gift, format: :json, gift: create_multiple_unique_gift(gift) , shoppingCart: @cart , token: @user.remember_token
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru not full gift of  unique ids for a user object with #{type_of}" do
                # add one unique id to the user record
                @user.update_attribute(type_of, identifier)
                # create a gift with multiple new social ids
                missing_hsh = gift_social_id_hsh
                if type_of == "phone"
                    missing_hsh["receiver_email"] = ""
                else
                    missing_hsh["receiver_phone"] = ""
                end
                gift = FactoryGirl.create :gift, missing_hsh
                post :create_gift, format: :json, gift: create_multiple_unique_gift(gift, missing_hsh) , shoppingCart: @cart , token: @user.remember_token
                # check that the :action assign the user_id to receiver_id and saves the gift
                new_gift = Gift.find(json["success"]["Gift_id"])
                new_gift.receiver_id.should == @user.id
            end
        end

        # Git should valide total and service
        
    end

    def gift_social_id_hsh
        {
            receiver_email: "jon@gmail.com",
            receiver_phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }
    end

    def create_multiple_unique_gift gift, missing_hsh=nil
        missing_hsh ||= gift_social_id_hsh
        {
            total:          gift.total,
            service:        gift.service,
            receiver_name:  gift.receiver_name,
            provider_id:    gift.provider.id,
            credit_card:    gift.credit_card
        }.merge(missing_hsh).to_json
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