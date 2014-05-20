require 'spec_helper'

describe Client::V3::UsersController do

    describe :index do

        it "should return basic contacts" do
            10.times do
                FactoryGirl.create(:user, iphone_photo: "http://res.cloudinary.com/drinkboard/image/upload/v1398470766/avatar_blank_cvblvd.png")
            end
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Array
            json["data"].count.should == 10
            first_user = json["data"].first
            keys = ["user_id", "first_name", "last_name", "photo"]
            compare_keys(first_user, keys)
        end
    end



end