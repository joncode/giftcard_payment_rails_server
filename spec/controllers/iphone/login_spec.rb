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
            json["error"].should   == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
        end

        it "should record user's pn token" do
            token = "912834198qweasdasdfasdfarqwerqwe3439487123"
            post :login, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.status.should         == 200
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
        end

    end

    describe :login_social do

        before do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: "faceface", twitter: "tweettweet" }
        end

        it "is successful with correct facebook" do
            post :login_social, format: :json, origin: "f", facebook_id: @user.facebook_id, twitter: nil
            response.status.should         == 200
            json["user"]["user_id"].should == @user.id.to_s
        end

        it "is successful with correct twitter" do
            post :login_social, format: :json, origin: "t", facebook_id: nil, twitter: @user.twitter
            response.status.should         == 200
            json["user"]["user_id"].should == @user.id.to_s
        end

        it "returns not in db with incorrect facebook" do
            post :login_social, format: :json, origin: "f", facebook_id: "face", twitter: nil
            response.status.should         == 200
            json["facebook"].should == "Facebook Account not in #{SERVICE_NAME} database"
        end

        it "returns not in db with incorrect twitter" do
            post :login_social, format: :json, origin: "t", facebook_id: nil, twitter: "tweet"
            response.status.should         == 200
            json["twitter"].should == "Twitter Account not in #{SERVICE_NAME} database"
        end

        it "returns invalid error if facebook and twitter are blank" do
            post :login_social, format: :json, origin: "f", facebook_id: nil, twitter: nil
            response.status.should         == 200
            json["error_iphone"].should   == "Data not received."
        end

        it "should record user's pn token" do
            token = "91283419asdfasdfadadsfasdfasdf83439487123"
            post :login_social, format: :json, origin: "f", facebook_id: @user.facebook_id, pn_token: token
            response.status.should         == 200
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
        end

        it "should not login a paused user" do
            @user.update_attribute(:active,false)

            post :login_social, format: :json, origin: "f", facebook_id: @user.facebook_id, twitter: nil
            response.status.should == 200
            json["error"].should   == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"

            post :login_social, format: :json, origin: "t", facebook_id: nil, twitter: @user.twitter
            response.status.should == 200
            json["error"].should   == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
        end
    end
end