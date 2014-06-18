require 'spec_helper'

describe Client::V3::CardsController do


    describe :index do

        it "should get all cards for user with GET params :user_id" do
            @user = FactoryGirl.create(:user, iphone_photo: "http://photo_urlimportante.com")
            request.env["HTTP_X_AUTH_TOKEN"] = @user.remember_token
            visa  = FactoryGirl.create(:visa, user_id: @user.id)
            amex  = FactoryGirl.create(:amex, user_id: @user.id)
            mastercard  = FactoryGirl.create(:mastercard, user_id: @user.id)
            get :index, format: :json, user_id: @user.id
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Array
            json["data"].count.should == 3
            ary = json["data"].first
            ary["user_id"].should == @user.id
        end

    end

end
