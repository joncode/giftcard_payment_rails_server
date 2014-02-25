require 'spec_helper'

describe Mdot::V2::FacebookController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    describe :index do

        SOCIAL_PROXY_URL = "http://m.itson.me/api/facebook.json"

        it_should_behave_like("token authenticated", :get, :index)

        it "should return a facebook friends array when success" do
            "birthday"  : "10/05/1987",
            "network_id": "27428352",
            "network"   : "facebook",
            "name"      : "Taylor Addison",
            "photo"     : "https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Array
        end

        it "should optionally accept oauth keys and save/update them" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Array
        end

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "Oauth keys have expired"
        end

        it "should hit social proxy URL with correct request" do
            stub_request(:post, SOCIAL_PROXY_URL).to_return(:status => 200, :body => "{}", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"]
            WebMock.should have_requested(:post, SOCIAL_PROXY_URL).with { |req|
                puts req.inspect
            }.once
        end

        it "should convert facebook specific proxy response into generic friend array response" do
            facebook_friends_response = []
            facebook_keys             = facebook_friends_response.first.keys
            stub_request(:post, SOCIAL_PROXY_URL).to_return(:status => 200, :body => "{}", :headers => {})
            request.env["HTTP_TKN"]   = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should    == 1
            keys = json["data"].first.keys
            compare_keys(facebook_keys, keys)
        end

        it "should authenticate with the social proxy" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :index, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"]
        end

    end

end