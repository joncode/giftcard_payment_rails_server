require 'spec_helper'

describe Mdot::V2::FacebookController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user    = FactoryGirl.create(:user)
            @user.update(remember_token: "USER_TOKEN")
        end
        @oauth        = FactoryGirl.create(:oauth_fb, user: @user)
        @oauth_hsh_fb = @oauth.to_proxy
    end

    describe :friends do

        let(:route) { "http://qam.itson.me/api/facebook/friends" }
        let(:fb_friends) { [{"network_id"=>"27428352","network"=>"facebook","name"=>"Taylor Addison","photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg","birthday"=>"10/05/1987"}].to_json}

        it_should_behave_like("token authenticated", :get, :friends)
        it_should_behave_like("proxy_auth_required", :get, :friends)

        it "should return a facebook friends array when success" do
            stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_friends}", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :friends, format: :json
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Array
            resp_hsh = json["data"].first
            fb_hsh = JSON.parse fb_friends
            compare_keys(resp_hsh, fb_hsh.first.keys)
        end

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :friends, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end
    end

    describe :profile do

        let(:route) { "http://qam.itson.me/api/facebook/profile" }
        let(:fb_resp) { { "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}.to_json }

        it_should_behave_like("token authenticated", :get, :profile)
        it_should_behave_like("proxy_auth_required", :get, :profile)

        it "should return a json hsh of user info when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_resp}", :headers => {})
            get :profile, format: :json
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == String
            json["data"].should       == fb_resp
        end

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :profile, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end
    end

    describe :create do
        let(:fb_resp) { [{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"},{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json }
        let(:route) { "http://qam.itson.me/api/facebook/story" }

        it_should_behave_like("token authenticated", :post, :create)
        it_should_behave_like("proxy_auth_required", :post, :create)

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_fb["token"]}\",\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :create, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end
    end

    describe :oauth do

        it_should_behave_like("token authenticated", :post, :oauth)

        it "should not require oauth tokens in database" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            oauth = @user.oauths.first
            oauth.destroy
            oauth_hsh = { "token" => "new_token", "network_id" => "987654321"}
            post :oauth, format: :json, data: oauth_hsh
            rrc(200)
        end

        it "should accept oauth hash and save in db with network == facebook" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            oauth = @user.oauths.first
            oauth.destroy
            @user.oauths.count.should == 0
            oauth_hsh = { "token" => "new_token", "network_id" => "987654321"}
            post :oauth, format: :json, data: oauth_hsh
            rrc(200)

            oauth = @user.oauths.first
            oauth.should_not be_nil
            oauth.token.should      == oauth_hsh["token"]
            oauth.network.should    == "facebook"
            oauth.network_id.should == oauth_hsh["network_id"]
        end

        it "should update oauth for network if already exists" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            oauth     = @user.oauths.first
            oauth_id  = oauth.id
            oauth.should_not be_nil
            oauth_hsh = { "token" => "new_token", "network_id" => oauth.network_id}
            post :oauth, format: :json, data: oauth_hsh
            rrc(200)

            oauth = @user.oauths.first
            oauth.should_not be_nil
            oauth.token.should      == oauth_hsh["token"]
            oauth.network.should    == "facebook"
            oauth.network_id.should == oauth_hsh["network_id"]
            oauth.id.should         == oauth_id
        end

        it "should require :token , :network_id or reply :bad_request" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            bad_oauth_hsh1 = { "network_id" => "987654321"}
            post :oauth, format: :json, data: bad_oauth_hsh1
            rrc(400)
            bad_oauth_hsh2 = { "token" => "987654321"}
            post :oauth, format: :json, data: bad_oauth_hsh2
            rrc(400)
        end

    end
end















