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
            two_gifts = Gift.where(receiver_id: user.id).limit(2)
            two_gifts.each { |g| g.update(giver_id: user.id, giver_name: user.name)}
            @user = user
            other_user = FactoryGirl.create(:user)
            11.times do
                FactoryGirl.create(:gift,giver: other_user, receiver_id: user.id + 2, receiver_name: "antoher person")
            end
        end

        it "should serialize the gifts with defined keys" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["status"].should == 1
            gift_hsh = json["data"].first
            keys = ["created_at"  ,"giv_name" ,"giv_photo"   ,"giv_id"      ,"giv_type"    ,"rec_id"      ,"rec_name"    ,"rec_photo"   ,"items"       ,"value"       ,"status"      ,"cat"       ,"msg"         ,"loc_id"     ,"loc_name"    ,"loc_phone"   ,"loc_address" ,"gift_id"]
            compare_keys(gift_hsh, keys)
        end

        it "should sent the users sent and received gifts in one array via GET params" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["data"].class.should == Array
            ary_num = json["data"].count
            flat_num = json["data"].flatten.count
            ary_num.should == flat_num
        end

        it "should not send duplicate gifts" do
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["data"].count.should  == 13
        end

    end


end

