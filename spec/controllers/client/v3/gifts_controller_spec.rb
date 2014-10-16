require 'spec_helper'

describe Client::V3::GiftsController do

    describe :index do

        before(:each) do
            user = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            6.times do
                FactoryGirl.create(:gift, giver_type: "User", cat: 300, giver_id: user.id, giver_name: user.name, expires_at: Time.now, redeemed_at: Time.now, message: "here is messag", detail: "here is detail")
            end
            7.times do
                FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name)
            end
            two_gifts  = Gift.where(receiver_id: user.id).limit(2)
            two_gifts.each { |g| g.update(giver_id: user.id, giver_name: user.name)}
            @user      = user
            other_user = FactoryGirl.create(:user)
            11.times do
                FactoryGirl.create(:gift, giver: other_user, receiver_id: user.id + 2, receiver_name: "antoher person")
            end
            request.env["HTTP_X_AUTH_TOKEN"] = user.remember_token
        end

        it_should_behave_like("client-token authenticated", :get, :index)

        it "should serialize the gifts with defined keys" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["status"].should == 1
            gift_hsh              = json["data"].first
            keys = ["created_at", "giv_name", "giv_photo", "giv_id", "giv_type", "rec_name", "rec_photo", "items", "value", "status", "expires_at", "cat", "msg", "loc_id", "loc_name", "loc_phone", "loc_address", "gift_id"]
            if gift_hsh["status"] == 'open'
                keys << 'rec_id'
            end
            compare_keys(gift_hsh, keys)
        end

        it "should send the users sent and received gifts in one array via GET params" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["data"].class.should == Array
            ary_num                   = json["data"].count
            flat_num                  = json["data"].flatten.count
            ary_num.should            == flat_num
        end

        it "should send the current_users sent and received gifts in one array via GET params if no user_id is present" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["data"].class.should == Array
            ary_num                   = json["data"].count
            flat_num                  = json["data"].flatten.count
            ary_num.should            == flat_num
        end

        it "should not send duplicate gifts" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["data"].count.should  == 13
        end

    end

    describe :open do

        before(:each) do
            @user = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            @rec  = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            request.env["HTTP_X_AUTH_TOKEN"] = @rec.remember_token
        end

        it_should_behave_like("client-token authenticated", :put, :open, id: 100)

        it "should change a gift from open to notified" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, receiver_id: @rec.id,  giver_id: @user.id, giver_name: @user.name, expires_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'open')
            put :open, format: :json, id: gift.id
            json["status"].should     == 1
            gift.reload.status.should == 'notified'
        end

        it "should return the new gift dictionary" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, giver_id: @user.id, receiver_id: @rec.id, giver_name: @user.name, expires_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'open')
            put :open, format: :json, id: gift.id
            json["status"].should     == 1
            gift_hsh                  = json["data"]
            gift_hsh["status"].should == 'notified'
            keys = ["expires_at", "detail","created_at"  ,"giv_name" ,"giv_photo"   ,"giv_id"      ,"giv_type"    ,"rec_id"      ,"rec_name"    ,"rec_photo"   ,"items"       ,"value"       ,"status"      ,"cat"       ,"msg"         ,"loc_id"     ,"loc_name"    ,"loc_phone"   ,"loc_address" ,"gift_id"]
            compare_keys(gift_hsh, keys)
        end

        it "should not change a gift that is not open" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, giver_id: @user.id, giver_name: @user.name, expires_at: Time.now, redeemed_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'redeemed')
            put :open, format: :json, id: gift.id
            gift.status.should == 'redeemed'
        end

    end

    describe :redeem do

        before(:each) do
            @user = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            @rec  = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            request.env["HTTP_X_AUTH_TOKEN"] = @rec.remember_token
        end

        it_should_behave_like("client-token authenticated", :put, :redeem, id: 100)

        it "should change a gift from notified to redeemed" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, receiver_id: @rec.id,  giver_id: @user.id, giver_name: @user.name, expires_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'redeemed')
            put :redeem, format: :json, id: gift.id
            json["status"].should     == 1
            gift.reload.status.should == 'redeemed'
        end

        it "should return the new gift dictionary" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, giver_id: @user.id, receiver_id: @rec.id, giver_name: @user.name, expires_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'redeemed')
            put :redeem, format: :json, id: gift.id
            json["status"].should     == 1
            gift_hsh                  = json["data"]
            gift_hsh["status"].should == 'redeemed'
            keys = ["expires_at", "detail","created_at"  ,"giv_name" ,"giv_photo"   ,"giv_id"      ,"giv_type"    ,"rec_id"      ,"rec_name"    ,"rec_photo"   ,"items"       ,"value"       ,"status"      ,"cat"       ,"msg"         ,"loc_id"     ,"loc_name"    ,"loc_phone"   ,"loc_address" ,"gift_id"]
            compare_keys(gift_hsh, keys)
        end

        it "should not change a gift that is not notified" do
            gift = FactoryGirl.create(:gift, giver_type: "User", cat: 300, giver_id: @user.id, giver_name: @user.name, expires_at: Time.now, redeemed_at: Time.now, message: "here is messag", detail: "here is detail")
            gift.update(status: 'expired')
            put :redeem, format: :json, id: gift.id
            gift.status.should == 'expired'
        end

    end

end

