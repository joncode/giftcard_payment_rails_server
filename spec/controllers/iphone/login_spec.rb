require 'spec_helper'

include MocksAndStubs

describe IphoneController do

    describe :login do

        before(:each) do
            @user = FactoryGirl.create :user, { email: "neil@gmail.com", password: "password", password_confirmation: "password" }
             ResqueSpec.reset!
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
            stub_request(:put, "https://q_NVI6G1RRaOU49kKTOZMQ:yQEhRtd1QcCgu5nXWj-2zA@go.urbanairship.com/api/device_tokens/#{token}").with(:body => "{\"alias\":\"user-#{@user.obscured_id}\",\"provider\":\"ios\"}",:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => "", :headers => {})
            post :login, format: :json, email: "neil@gmail.com", password: "password", pn_token: token
            # PnToken.any_instance.stub(:register)
            run_delayed_jobs
            response.status.should         == 200
            pn_token = PnToken.where(pn_token: token).first
            pn_token.pn_token.should == token
            pn_token.class.should    == PnToken
            pn_token.user_id.should  == @user.id
        end

        it "should hit urban airship endpoint with correct token and alias" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            PnToken.any_instance.stub(:ua_alias).and_return("fake_ua")
            User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
            SubscriptionJob.stub(:perform).and_return(true)
            MailerJob.stub(:call_mandrill).and_return(true)

            pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            ua_alias = "fake_ua"

            Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias, :provider => :ios})

            post :login, format: :json, email: "neil@gmail.com", password: "password", pn_token: pn_token
            #PnToken.any_instance.stub(:register)
            run_delayed_jobs # ResqueSpec.perform_all(:push)
        end

    end

    describe :login_social do

        before do
             ResqueSpec.reset!
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
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
            resque_stubs
            token = "91283419asdfasdfadadsfasdfasdf83439487123"
            post :login_social, format: :json, origin: "f", facebook_id: @user.facebook_id, pn_token: token
            response.status.should         == 200
            PnToken.any_instance.stub(:register)
            run_delayed_jobs
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

        it "should hit urban airship endpoint with correct token and alias" do
            stub_request(:post, "https://mandrillapp.com/api/1.0/messages/send-template.json").to_return(:status => 200, :body => "{}", :headers => {})
            stub_request(:post, "https://us7.api.mailchimp.com/2.0/lists/subscribe.json").to_return(:status => 200, :body => "{}", :headers => {})
            PnToken.any_instance.stub(:ua_alias).and_return("fake_ua")
            User.any_instance.stub(:pn_token).and_return("FAKE_PN_TOKENFAKE_PN_TOKEN")
            resque_stubs register_push: true
            pn_token = "FAKE_PN_TOKENFAKE_PN_TOKEN"
            ua_alias = "fake_ua"

            Urbanairship.should_receive(:register_device).with(pn_token, { :alias => ua_alias, :provider => :ios })

            post :login_social, format: :json, origin: "f", facebook_id: @user.facebook_id, pn_token: pn_token
            run_delayed_jobs # ResqueSpec.perform_all(:push)
        end


    end
end