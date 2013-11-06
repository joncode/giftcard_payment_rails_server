require 'spec_helper'

describe Mdot::V2::SessionsController do

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

        it "is successful" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"].should    == @user.id.to_s
        end

        it "returns invalid error if password is incorrect" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "passwo121rd"
            response.status.should == 200
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end

        it "returns invalid error if email is incorrect" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil12@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end

        it "should not login a paused user" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.active = false
            @user.save
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 0
            json["data"].should    == "We're sorry, this account has been suspended.  Please contact support@drinkboard.com for details"
        end
    end

    describe :login_social do
        it_should_behave_like("token authenticated", :post, :login_social)

    end


end
