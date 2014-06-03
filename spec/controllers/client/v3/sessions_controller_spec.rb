require 'spec_helper'

describe Client::V3::SessionsController do

    describe :create do

        it "should return basic contacts" do
			user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: "faceface", twitter: "tweettweet" }
    		request_hsh = { email: "neil@gmail.com", password: "password"}
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 1
            json["data"].class.should == Hash 
            json["data"]["user_id"].should == user.id
        end
    end

end



