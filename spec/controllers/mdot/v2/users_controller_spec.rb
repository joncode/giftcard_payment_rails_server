require 'spec_helper'

describe Mdot::V2::UsersController do

    before(:all) do
        User.delete_all
        unless @user = User.find_by_remember_token("TokenGood")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "TokenGood")
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        before(:each) do
            20.times do |index|
                FactoryGirl.create(:user, first_name: "Newbiee#{index}")
            end
            user = User.last
            user.update_attribute(:active, false)
        end

        it "should return a list of active users" do
            request.env["HTTP_TKN"] = "TokenGood"
            amount  = User.where(active: true).count
            keys    = ["email", "facebook_id", "first_name", "last_name", "phone", "twitter", "photo", "user_id"]
            get :index, format: :json
            response.response_code.should == 200
            json["status"].should == 1
            ary = json["data"]
            ary.class.should == Array
            ary.count.should == amount
            hsh = ary.first
            compare_keys(hsh, keys)
        end
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update)

        it "should require a update_user hash" do
            request.env["HTTP_TKN"] = "TokenGood"
            put :update, format: :json, data: "updated data"
            response.response_code.should == 400
            put :update, format: :json, data: nil
            response.response_code.should == 400
            put :update, format: :json
            response.response_code.should == 400
        end

        it "should return user hash when success" do
            request.env["HTTP_TKN"] = "TokenGood"
            put :update, format: :json, data: { zip: "89475", sex: "male", birthday: "03/13/1975"}
            response.response_code.should == 200
            json["status"].should == 1
            response = json["data"]
            response.class.should  == Hash
            keys = ["user_id", "first_name", "last_name" ,"zip", "email", "phone", "photo", "birthday", "sex", "twitter", "facebook_id"]
            compare_keys(response, keys)
        end

        it "should return validation errors" do
            request.env["HTTP_TKN"] = "TokenGood"
            put :update, format: :json, data: { "email" => "" }
            json["status"].should == 0
            json["data"].class.should    == Hash
            json["data"]["email"].should == ["is invalid"]
        end

        {
            first_name: "Ray",
            last_name:  "Davies",
            email: "ray@davies.com",
            phone: "5877437859",
            birthday: "10/10/1971",
            sex: "female",
            zip: "85733",
            phone: "(702) 410-9605",
            twitter: "65787323",
            facebook_id: "98136459814"
        }.stringify_keys.each do |type_of, value|

            it "should update the user #{type_of} in database" do
                request.env["HTTP_TKN"] = "TokenGood"
                put :update, format: :json, data: { type_of => value }
                new_user = @user.reload
                value = "7024109605" if value == "(702) 410-9605"
                new_user.send(type_of).should == value
            end
        end

        it "should not update attributes that dont exist and succeed" do
            request.env["HTTP_TKN"] = "TokenGood"
            hsh = { "house" => "chill" }
            put :update, format: :json, data: hsh
            response.response_code.should == 400
        end

        it "should not update attributes that are not allowed and still succeed" do
            request.env["HTTP_TKN"] = "TokenGood"
            hsh = { "password" => "doNOTallow", "remember_token" => "DO_NOT_ALLOW" }
            put :update, format: :json, data: hsh
            response.response_code.should == 400
        end
    end

    describe :reset_passord do
        it_should_behave_like("token authenticated", :put, :reset_password)

    end


end

