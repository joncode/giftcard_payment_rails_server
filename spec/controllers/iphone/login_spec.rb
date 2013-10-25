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

end