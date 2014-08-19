require 'spec_helper'

describe Web::V3::SessionsController do

    describe :create do

        it "should return basic contacts" do
            user                      = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: "faceface", twitter: "tweettweet" }
            request_hsh               = { username: "neil@gmail.com", password: "password"}
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Hash
            json["data"]["user_id"].should == user.id
        end

        it "should login with facebook return basic contacts" do
            user                      = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: "faceface", twitter: "tweettweet" }
            request_hsh               = { fb_user_id: "faceface", fb_token: "token"}
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Hash
            json["data"]["user_id"].should == user.id
        end

        context "Failure Messages" do
	        it "should return correct error format for email/password not found" do
	            request_hsh               = { username: "fakeuser@gmail.com", password: "password"}
	            post :create, format: :json, data: request_hsh
	            rrc(404)
	            json["status"].should     == 0
	            json["err"].should == "INVALID_CREDENTIALS"
	            json["msg"].should == "We don't recognize that email and password combination"
	            json["data"].should == []
	        end

	        it "should return correct error format for facebook not found" do
	            request_hsh               = { fb_user_id: "faceface", fb_token: "token"}
	            post :create, format: :json, data: request_hsh
	            rrc(404)
	            json["status"].should == 0
	            json["err"].should    == "INVALID_CREDENTIALS"
	            json["msg"].should    == "We don't recognize that facebook account"
	            json["data"].should   == []
	        end

	        it "should return correct error format for suspended user" do
	        	suspended_user = FactoryGirl.create :user, email: "suspended@gmail.com", password: "password", password_confirmation: "password", active: false
	            request_hsh    = { username: "suspended@gmail.com", password: "password" }
	            post :create, format: :json, data: request_hsh
	            rrc(401)
	            json["status"].should     == 0
	            json["err"].should == "UNAUTHORIZED_CREDENTIALS"
	            json["msg"].should == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
	            json["data"].should == []
	        end
	    end
    end

end



