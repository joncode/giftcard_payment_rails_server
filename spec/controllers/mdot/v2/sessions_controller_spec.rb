require 'spec_helper'

describe Mdot::V2::SessionsController do

    before do
        @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password", facebook_id: "faceface", twitter: "tweettweet" }
    end

    describe :create do
        it_should_behave_like("token authenticated", :post, :create)

        it "should accept ANDROID token for authentication" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "is successful" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should find secondary email and login successful" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.update_attributes({email: "twofold@gmail.com"})
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should return serialized user when success" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            keys = ["email", "facebook_id", "first_name", "last_name", "phone", 'zip', "birthday", "twitter", "photo", "user_id", "token"]
            hsh  = json["data"]
            compare_keys(hsh, keys)
        end

        it "returns invalid error if password is incorrect" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "passwo121rd"
            response.status.should == 404
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end


        it "should not allow corrupted / missing email or password" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: {"hello" =>"neil@gmail.com" }, password: "passwo121rd"
            response.status.should == 400
            post :create, format: :json, email: "neil@gmail.com"
            response.status.should == 400
            post :create, format: :json, password: "passwo121rd"
            response.status.should == 400
            post :create, format: :json, email: "neil@gmail.com", password: ["passwo121rd"]
            response.status.should == 400
            post :create, format: :json, email: nil, password: "passwo121rd"
            response.status.should == 400
            post :create, format: :json, email: "neil@gmail.com", password: ""
            response.status.should == 400
        end

        it "should reject any request with extra keys" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password", faker: "FAKE"
            rrc 400
        end

        it "returns invalid error if email is incorrect" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :create, format: :json, email: "neil12@gmail.com", password: "password"
            response.status.should == 404
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end

        it "should not login a paused user" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.active = false
            @user.save
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 401
            json["status"].should  == 0
            json["data"].should    == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
        end

        it "should not save bad pn token but allow login" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "9128341983439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.response_code.should   == 200
            json["status"].should  == 1
            json["data"]["user_id"].should  == @user.id
        end

        it "should record user's pn token" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "91283419asdfasdfasdfasdfasdfa83439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.status.should   == 200
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
        end
    end

    describe :login_social do
        it_should_behave_like("token authenticated", :post, :login_social)

        it "should accept ANDROID token for authentication" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            post :login_social, format: :json, facebook_id: @user.facebook_id
            response.status.should         == 200
            json["status"].should          == 1
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with primary facebook" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :login_social, format: :json, facebook_id: @user.facebook_id
            response.status.should         == 200
            json["status"].should          == 1
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with primary twitter" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :login_social, format: :json, twitter: @user.twitter
            response.status.should         == 200
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with secondary facebook" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.update_attributes({facebook_id: "823472938429"})
            post :login_social, format: :json, facebook_id: "faceface"
            response.status.should         == 200
            json["status"].should          == 1
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with secondary twitter" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.update_attributes({twitter: "127653723"})
            post :login_social, format: :json, twitter: "tweettweet"
            response.status.should         == 200
            json["data"]["user_id"].should == @user.id
        end

        it "returns not in db with incorrect facebook" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :login_social, format: :json, facebook_id: "face"
            response.status.should  == 404
            json["data"].should == "Account not in #{SERVICE_NAME} database"
        end

        it "returns not in db with incorrect twitter" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :login_social, format: :json, twitter: "tweet"
            response.status.should == 404
            json["data"].should == "Account not in #{SERVICE_NAME} database"
        end

        it "returns invalid error if facebook and twitter are blank" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            post :login_social, format: :json
            response.status.should        == 400
            post :login_social, format: :json, facebook_id: nil
            response.status.should        == 400
            post :login_social, format: :json, twitter: nil
            response.status.should        == 400
            post :login_social, format: :json, facebook_id: ""
            response.status.should        == 400
            post :login_social, format: :json, twitter: ""
            response.status.should        == 400
        end

        it "should not save bad pn token but allow login" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "9128341983439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.response_code.should   == 200
            json["status"].should  == 1
            json["data"]["user_id"].should  == @user.id
        end

        it "should record user's pn token" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            token = "91283419asdfasdfasdfasdfasdfa83439487123"
            post :login_social, format: :json, facebook_id: @user.facebook_id, pn_token: token
            response.status.should   == 200
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
        end

        it "should not login a paused user" do
            request.env["HTTP_TKN"] = GENERAL_TOKEN
            @user.update_attribute(:active,false)

            post :login_social, format: :json, facebook_id: @user.facebook_id
            response.status.should == 401
            json["status"].should == 0
            json["data"].should   == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"

            post :login_social, format: :json, twitter: @user.twitter
            response.status.should == 401
            json["status"].should == 0
            json["data"].should   == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
        end

    end


end
