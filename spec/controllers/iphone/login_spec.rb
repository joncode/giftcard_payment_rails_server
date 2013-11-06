require 'spec_helper'

describe IphoneController do

    describe "#login" do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
        end

        it "is successful" do
            post :login, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should         == 200
            json["user"]["user_id"].should == @user.id.to_s
        end

        it "returns invalid error if password is incorrect" do
            post :login, format: :json, email: "neil@gmail.com", password: "passwo121rd"
            response.status.should == 200
            json["error"].should   == "Invalid email/password combination"
        end

        it "returns invalid error if email is incorrect" do
            post :login, format: :json, email: "neil12@gmail.com", password: "password"
            response.status.should == 200
            json["error"].should   == "Invalid email/password combination"
        end

        it "should not login a paused user" do
            @user.active = false
            @user.save
            post :login, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["error"].should   == "We're sorry, this account has been suspended.  Please contact support@drinkboard.com for details"
        end

    end

    describe :login_social do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password",
                                                facebook_id: "faceface", twitter: "tweettweet" }
        end

        it "is successful with correct facebook" do
            post :login_social, format: :json, origin: "f", facebook_id: "faceface", twitter: nil 
            response.status.should         == 200
            json["user"]["user_id"].should == @user.id.to_s
        end

        it "is successful with correct twitter" do
            post :login_social, format: :json, origin: "t", facebook_id: nil, twitter: "tweettweet" 
            response.status.should         == 200
            json["user"]["user_id"].should == @user.id.to_s
        end

        it "returns not in db with incorrect facebook" do
            post :login_social, format: :json, origin: "f", facebook_id: "face", twitter: nil 
            response.status.should         == 200
            json["facebook"].should == "Facebook Account not in Drinkboard database"
        end

        it "returns not in db with incorrect twitter" do
            post :login_social, format: :json, origin: "t", facebook_id: nil, twitter: "tweet" 
            response.status.should         == 200
            json["twitter"].should == "Twitter Account not in Drinkboard database"
        end

        it "returns invalid error if facebook and twitter are blank" do
            post :login_social, format: :json, origin: "f", facebook_id: nil, twitter: nil 
            response.status.should         == 200
            json["error_iphone"].should   == "Data not received."
        end

    end


end