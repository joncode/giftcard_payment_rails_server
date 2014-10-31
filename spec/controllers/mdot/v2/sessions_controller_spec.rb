require 'spec_helper'

include UserSessionFactory
include MocksAndStubs

describe Mdot::V2::SessionsController do

    before(:each) do
        User.any_instance.stub(:init_confirm_email).and_return(true)
        SubscriptionJob.stub(:perform)
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

        it "should accept APP GENERAL TOKEN token for authentication" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should log in joe meeks bug fix" do
            request.env["HTTP_TKN"] = ANDROID_TOKEN
            post :create, format: :json, "email"=>"joe.meeks@sos.me", "password"=>"joem420", "session"=>{"email"=>"joe.meeks@sos.me", "password"=>"joem420"}
            rrc 400
        end

        it "is successful" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should find secondary email and login successful" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            @user.update_attributes({email: "twofold@gmail.com"})
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should log in when email is sent not downcased" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "Neil@gmail.com", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should log in when email is sent with trailing whitespace" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com   ", password: "password"
            response.status.should == 200
            json["status"].should  == 1
            json["data"]["user_id"].should    == @user.id
        end

        it "should return serialized user when success" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 200
            keys = ["email", "facebook_id", "first_name", "last_name", "phone", 'zip', "birthday", "twitter", "photo", "user_id", "token"]
            hsh  = json["data"]
            compare_keys(hsh, keys)
        end

        it "returns invalid error if password is incorrect" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "passwo121rd"
            response.status.should == 404
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end


        it "should not allow corrupted / missing email or password" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
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
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil@gmail.com", password: "password", faker: "FAKE"
            rrc 400
        end

        it "returns invalid error if email is incorrect" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :create, format: :json, email: "neil12@gmail.com", password: "password"
            response.status.should == 404
            json["status"].should  == 0
            json["data"].should    == "Invalid email/password combination"
        end

        it "should not login a paused user" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            @user.active = false
            @user.save
            post :create, format: :json, email: "neil@gmail.com", password: "password"
            response.status.should == 401
            json["status"].should  == 0
            json["data"].should    == "We're sorry, this account has been suspended.  Please contact #{SUPPORT_EMAIL} for details"
        end

        it "should not save bad pn token but allow login" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            token = "9128341983439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.response_code.should   == 200
            json["status"].should  == 1
            json["data"]["user_id"].should  == @user.id
        end

        it "should record user's pn token" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            test_pn_token_persisted do |token|
                post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
                'ios'
            end
            response.status.should   == 200
        end

        it "should record user's pn token and platform" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            token = "91283419asdfasdfasdfasdfasdfa83439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token, platform: "android"
            response.status.should   == 200
            RegisterPushJob.stub(:ua_register)
            run_delayed_jobs
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
            pn_token.platform.should == "android"
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
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json, facebook_id: @user.facebook_id
            response.status.should         == 200
            json["status"].should          == 1
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with primary twitter" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json, twitter: @user.twitter
            response.status.should         == 200
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with secondary facebook" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            @user.update_attributes({facebook_id: "823472938429"})
            post :login_social, format: :json, facebook_id: "faceface"
            response.status.should         == 200
            json["status"].should          == 1
            json["data"]["user_id"].should == @user.id
        end

        it "is successful with secondary twitter" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            @user.update_attributes({twitter: "127653723"})
            post :login_social, format: :json, twitter: "tweettweet"
            response.status.should         == 200
            json["data"]["user_id"].should == @user.id
        end

        it "returns not in db with incorrect facebook" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json, facebook_id: "face"
            response.status.should  == 404
            json["data"].should == "Account not in #{SERVICE_NAME} database"
        end

        it "returns not in db with incorrect twitter" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json, twitter: "tweet"
            response.status.should == 404
            json["data"].should == "Account not in #{SERVICE_NAME} database"
        end

        it "returns invalid error if facebook and twitter are blank" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json
            rrc 400
            post :login_social, format: :json, facebook_id: nil
            rrc 400
            post :login_social, format: :json, twitter: nil
            rrc 400
            post :login_social, format: :json, facebook_id: ""
            rrc 400
            post :login_social, format: :json, twitter: ""
            rrc 400
        end

        it "should return 400 if anything other then facebook_id or twitter are sent" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            post :login_social, format: :json, session:  {"facebook_id"=>"1617770036", "session"=>{"facebook_id"=>"1617770036"}}
            rrc 400
            post :login_social, format: :json, facebook_id: "1617770036", session: {"facebook_id"=>"1617770036"}
            rrc 400
            post :login_social, format: :json, twitter: "76234237", session: {"twitter"=>"1617770036"}
            rrc 400
        end

        it "should not save bad pn token but allow login" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            token = "9128341983439487123"
            post :create, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            response.response_code.should   == 200
            json["status"].should  == 1
            json["data"]["user_id"].should  == @user.id
        end

        it "should record user's pn token" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
            test_pn_token_persisted do |token|
                post :login_social, format: :json, facebook_id: @user.facebook_id, pn_token: token, platform: 'android'
                'android'
            end
            response.status.should   == 200
        end

        it "should not login a paused user" do
            request.env["HTTP_TKN"] = APP_GENERAL_TOKEN
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

        it "should allow the ios app to log in with facebook BUG FIX" do
            #END MDOT/V2/SESSIONS -LOGIN_SOCIAL- (0.2ms) | Completed 400 Bad Request in 1ms (ActiveRecord: 0.0ms)
            #"/mdot/v2/sessions/login_social.json"
            @user.update(facebook_id: "100005169276525")
            request.env["HTTP_TKN"] =  "0NFXbWsyP3Mj2Mroj_utsA"
            params = {"facebook_id"=>100005169276525, "pn_token"=>"5afc778282c48f99cad2c1b791ac51ab3c14063bee3320e090e637636c82293a"}
            post :login_social, format: :json, facebook_id: params["facebook_id"], pn_token: params["pn_token"]
            rrc(200)
        end
    end


end
