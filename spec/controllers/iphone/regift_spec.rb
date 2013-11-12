require 'spec_helper'

describe IphoneController do

    before(:each) do
        Gift.delete_all
        User.delete_all
        UserSocial.delete_all
    end

    let(:cart)     { "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]" }

    describe "#regift" do

        let(:old_gift)  { FactoryGirl.create(:regift) }
        let(:giver)     { old_gift.giver }
        let(:regifter)  { old_gift.receiver }
        let(:receiver)  { FactoryGirl.create(:receiver) }
        let(:rec_json)  { regift_hash(receiver).to_json }

        it "should create a new gift" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.id.should == (old_gift.id + 1)
        end

        it "should create a new gift with correct giver" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.giver_name.should == regifter.name
            new_gift.giver_id.should   == regifter.id
        end

        it "should set the status of the old gift to regifted" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            old_gift_reloaded = Gift.find(old_gift.id)
            old_gift_reloaded.status.should == 'regifted'
        end

        it "should set the status of new gift to open" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.status.should == 'open'
        end

        it "should set the status of 'social identifier only gift' to incomplete" do
            no_id_user     = FactoryGirl.build(:nobody, :id => nil )
            hsh_no_id_user = regift_hash(no_id_user).to_json
            post :regift, format: :json, receiver: hsh_no_id_user, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.find_by(receiver_email: no_id_user.email)
            puts new_gift.inspect
            new_gift.status.should == 'incomplete'
        end

        it "should create 'social identifier only gift'" do
            no_id_user     = FactoryGirl.build(:nobody, :id => nil )
            hsh_no_id_user = regift_hash(no_id_user).to_json
            post :regift, format: :json, receiver: hsh_no_id_user, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.id.should == (old_gift.id + 1)
        end

        it "should add new message to new gift" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.message.should == "New Regift Message"
        end

        it "should copy the shopping cart to new gift" do
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
            new_gift = Gift.last
            new_gift.shoppingCart.should == "[{\"detail\":null,\"price\":13,\"quantity\":1,\"item_id\":82,\"item_name\":\"Original Margarita \"}]"
        end

    end

    describe "#regift security" do

        let(:old_gift)  { FactoryGirl.create(:regift) }
        let(:giver)     { old_gift.giver }
        let(:regifter)  { old_gift.receiver }
        let(:receiver)  { FactoryGirl.create(:receiver) }
        let(:rec_json)  { regift_hash(receiver).to_json }

        it "it should not allow regift for de-activated regifters" do
            regifter.update_attribute(:active, false)
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: regifter.remember_token
            puts "401 - LEARN TO HEADER TEST "
        end

        it "it should not allow regift to de-activated receivers" do
            receiver.update_attribute(:active, false)
            post :regift, format: :json, receiver: rec_json, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: regifter.remember_token
            puts "here is json inspect #{json.inspect}"
            json["status"].should          == 0
            json["data"].should   == 'User is no longer in the system , please gift to them with phone, email, facebook, or twitter'
        end

    end

    describe "#regift_to_socal_network_non_users" do

        before(:each) do
            @user = FactoryGirl.create :nonetwork
            @cart = "[{\"price\":\"10\",\"quantity\":3,\"section\":\"beer\",\"item_id\":782,\"item_name\":\"Budwesier\"}]"
        end

        {
            email: "jon@gmail.com",
            phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }.stringify_keys.each do |type_of, identifier|
            it "should find user account for old #{type_of}" do

                @user.update_attribute(type_of, identifier)
                if (type_of == "phone") || (type_of == "email")
                    key = "receiver_#{type_of}"
                else
                    key = type_of
                end
                old_gift = FactoryGirl.create :regift, { key => identifier}
                giver    = old_gift.giver
                recipient_data = regift_hash(@user).to_json
                post :regift, format: :json, receiver: recipient_data, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token

                puts json.inspect
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru multiple unique ids for a user object with #{type_of}" do
                @user.update_attribute(type_of, identifier)
                old_gift = FactoryGirl.create :regift, gift_social_id_hsh
                giver    = old_gift.giver
                recipient_data = regift_hash(@user).to_json
                post :regift, format: :json, receiver: recipient_data, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end

            it "should look thru not full gift of unique ids for a user object with #{type_of}" do
                @user.update_attribute(type_of, identifier)
                missing_hsh = gift_social_id_hsh
                if type_of == "phone"
                    missing_hsh["receiver_email"] = ""
                else
                    missing_hsh["receiver_phone"] = ""
                end
                old_gift  = FactoryGirl.create :regift, missing_hsh
                giver     = old_gift.giver
                recipient_data = regift_hash(@user).to_json
                post :regift, format: :json, receiver: recipient_data, data: { regift_id: old_gift.id, message: "New Regift Message" }.to_json , token: giver.remember_token
                new_gift = Gift.find(json["data"]["gift_id"])
                new_gift.receiver_id.should == @user.id
            end
        end

    end

    def regift_hash receiver
        user_data_hash = {}
        user_data_hash["receiver_id"]   = receiver.id
        user_data_hash["name"]          = receiver.name
        user_data_hash["email"]         = receiver.email
        user_data_hash["phone"]         = receiver.phone
        user_data_hash["facebook_id"]   = receiver.facebook_id
        user_data_hash["twitter"]       = receiver.twitter
        user_data_hash
    end

    def gift_social_id_hsh
        {
            receiver_email: "jon@gmail.com",
            receiver_phone: "9173706969",
            facebook_id: "123",
            twitter: "999"
        }
    end

end



        # recipient_data = JSON.parse params["receiver"]
        # details      = JSON.parse params["data"]
        # old_gift_id    = details["regift_id"]
        # message        = details["message"]
        # recipient = nil

        # if recipient_data["receiver_id"] && recipient_data["receiver_id"] > 0
        #     unless recipient = User.find(recipient_data["receiver_id"])
        #         puts "!!! APP SUBMITTED USER ID THAT DOESNT EXIST #{recipient_data} !!!"
        #         recipient = make_user_with_hash(recipient_data)
        #     end
        # else
        #     recipient = make_user_with_hash(recipient_data)
        # end

        # if recipient && (old_gift = Gift.find(old_gift_id.to_i))
        #     new_gift = old_gift.regift(recipient, message)
        #     new_gift.save
        #     old_gift.update_attribute(:status, 'regifted')
        #     new_gift.set_status_post_payment
        #     new_gift.save
        #     unless new_gift.receiver_id.nil?
        #       Relay.send_push_notification new_gift
        #     end
        #     success(new_gift.serialize)
        # else
        #     fail    data_not_found
        # end

        # respond