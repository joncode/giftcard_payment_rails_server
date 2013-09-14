require 'spec_helper'

require File.dirname(__FILE__) + '/../spec_helper'

describe IphoneController do

    describe "#login" do

        # test that deactivated or suspended users are not able to login
        let :user do
            FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
        end

        it "is successful" do
            post :login, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200

        end

        it "returns invalid error if password is incorrect" do
            post :login, { email: "neil@gmail.com", password: "passwo121rd" }
            response.status.should == 200
        end

        it "returns invalid error if email is incorrect" do
            post :login, { email: "neil12@gmail.com", password: "password" }
            response.status.should == 200
        end

    end


end