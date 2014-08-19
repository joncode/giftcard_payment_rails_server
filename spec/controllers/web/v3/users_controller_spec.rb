require 'spec_helper'

describe Web::V3::UsersController do

    describe :create do
    	before do
			request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
    	end

        it "should create user" do
            request_hsh = { 
            	first_name: "abe",
            	last_name: "anderson",
            	email: "abe@email.com",
            	password: "password",
            	password_confirmation: "password"
            }
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 1
            json["data"]["email"][0].should == { "_id" => UserSocial.last.id, "value" => "abe@email.com" }
        end

        it "should return correct error" do
            request_hsh = { 
            	first_name: "abe",
            	last_name: "anderson",
            	email: "abe@email.com",
            	password: "password",
            	password_confirmation: "wrong"
            }
            post :create, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should    == "INVALID_INPUT" 
            json["msg"].should    == "User could not be created"
            json["data"].should   == [{ "name" => "password_confirmation", "msg" => "doesn't match Password" }]
        end

    end
end
