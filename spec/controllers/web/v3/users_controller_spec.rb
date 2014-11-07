require 'spec_helper'

include UserSessionFactory

describe Web::V3::UsersController do

    describe "create" do

    	before(:each) do
            User.delete_all
			request.headers["HTTP_X_AUTH_TOKEN"] = WWW_TOKEN
    	end

        it_should_behave_like("client-token authenticated", :post, :create)

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
            json["data"].should   == [{ "name" => "password confirmation", "msg" => "doesn't match Password" }]
        end

    end

    describe "update" do

        it_should_behave_like("client-token authenticated", :patch, :update)

        it "should persist the data to the user record" do
            user = FactoryGirl.create(:user, last_name: "not_anderson")
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                last_name: "anderson"
            }
            patch :update, format: :json, data: request_hsh

            user.reload
            user.last_name.should == "Anderson"
        end

        it "should return a full json object of the user" do
            user = FactoryGirl.create(:user, last_name: "not_anderson")
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                last_name: "anderson"
            }
            patch :update, format: :json, data: request_hsh
            user.reload
            rrc(200)
            json["status"].should == 1
            json["data"].should == user.login_web_serialize
        end

        it "should update the individual user socials by id" do
            user = FactoryGirl.create(:user, last_name: "not_anderson", phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                social: [{ "_id" => user_social.id, "value" => "545-575-6879" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            user_social.reload
            user_social.identifier.should == "5455756879"
        end

        it "should create the individual user socials by id" do
            user = FactoryGirl.create(:user, last_name: "not_anderson", phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                social: [{ "net" => 'ph', "value" => "545-575-6879" }, { "_id" => user_social.id, "value" => "(432) 677-8999" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            user_social.reload
            user_social.identifier.should  == "4326778999"
            nuser_social                   = UserSocial.where(identifier: "5455756879").first
            nuser_social.identifier.should == "5455756879"
            nuser_social.type_of.should    == "phone"
        end

        it "should return email validation errors and not update anything" do
            user = FactoryGirl.create(:user, last_name: "not_anderson", email: "good@rmail.net")
            user_social = UserSocial.where(identifier: "good@rmail.net").first
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                last_name: "new_last_name",
                social: [{ "_id" => user_social.id, "value" => "newbieramil.net" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "User could not be created"
            json["data"].should == [{"name"=>"email", "msg"=>["is invalid"]}]
            user.reload
            user.last_name.should_not == "new_last_name"
            user_social.reload
            user_social.identifier.should == "good@rmail.net"
        end

        it "should allow updates to photo_url" do
            user = FactoryGirl.create(:user, last_name: "not_anderson")
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                photo: "http://res.cloudinary.com/drinkboard/upload/version/92364029/hnkjfasdoiyfliaeh.jpg"
            }
            patch :update, format: :json, data: request_hsh

            user.reload
            user.get_photo.should == "http://res.cloudinary.com/drinkboard/upload/version/92364029/hnkjfasdoiyfliaeh.jpg"
        end

        it "should return phone validation errors and not update anything" do
            user = FactoryGirl.create(:user, last_name: "not_anderson", phone: "4325654895")
            user_social = UserSocial.where(identifier: "4325654895").first
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh = {
                last_name: "new_last_name",
                social: [{ "_id" => user_social.id, "value" => "465-238-942" }]
            }
            patch :update, format: :json, data: request_hsh
            rrc(200)
            json["status"].should == 0
            json["err"].should == "INVALID_INPUT"
            json["msg"].should == "User could not be created"
            json["data"].should == [{"name"=>"identifier", "msg"=>["is invalid"]}]
            user.reload
            user.last_name.should_not == "new_last_name"
            user_social.reload
            user_social.identifier.should == "4325654895"
        end

        it "should accept the photo key BUG FIX" do
            user = FactoryGirl.create(:user, last_name: "not_anderson", phone: "4325654895")
            us = FactoryGirl.create(:user_social, user_id: user.id, type_of: "email", identifier: "roger1@rogerson.com")
            request.headers["HTTP_X_AUTH_TOKEN"] = user.remember_token
            request_hsh =  {"social"=>[{"_id"=>us.id, "value"=>"roger@rogerson.com"}, {"net"=>"ph", "value"=>"(702) 927-2102"}], "first_name"=>"Roger", "last_name"=>"Rogerson", "birthday"=>nil, "zip"=>nil, "sex"=>nil, "photo"=>nil}
            patch :update, format: :json, data: request_hsh
            rrc(200)
            us.reload.identifier.should == "roger@rogerson.com"
        end
    end
end
