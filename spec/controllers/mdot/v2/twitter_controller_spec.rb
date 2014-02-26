require 'spec_helper'

describe Mdot::V2::TwitterController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update(remember_token: "USER_TOKEN")
        end
        @oauth = FactoryGirl.create(:oauth, user: @user)
        @oauth_hsh_tw = @oauth.to_proxy
    end

    describe :friends do

        let(:route) { "http://qam.itson.me/api/twitter/friends" }
        let(:tw_friends) { [{"network_id"=>"27428352","handle"=>"razorback","name"=>"Taylor Addison","photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json}

        it_should_behave_like("token authenticated", :get, :friends)
        it_should_behave_like("proxy_auth_required", :get, :friends)

        it "should return a twitter friends array when success" do
            stub_request(:post, route).with(:body => "data[token]=#{@oauth_hsh_tw["token"]}&data[secret]=#{@oauth_hsh_tw["secret"]}&data[network_id]=#{@oauth_hsh_tw["network_id"]}&data[handle]=#{@oauth_hsh_tw["handle"]}", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}"}).to_return(:status => 200, :body => "#{tw_friends}", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :friends, format: :json
            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == Array
            resp_hsh = json["data"].first
            fb_hsh = JSON.parse tw_friends
            compare_keys(resp_hsh, fb_hsh.first.keys)
        end

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "data[token]=#{@oauth_hsh_tw["token"]}&data[secret]=#{@oauth_hsh_tw["secret"]}&data[network_id]=#{@oauth_hsh_tw["network_id"]}&data[handle]=#{@oauth_hsh_tw["handle"]}", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}"}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :friends, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end

    end

    describe :profile do
        let(:tw_resp) { {"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" }.to_json }
        let(:route) { "http://qam.itson.me/api/twitter/account" }


        it_should_behave_like("token authenticated", :get, :profile)
        it_should_behave_like("proxy_auth_required", :get, :profile)

        it "should return a json hsh of user info when success" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            stub_request(:post, route).with(:body => "data[token]=#{@oauth_hsh_tw["token"]}&data[secret]=#{@oauth_hsh_tw["secret"]}&data[network_id]=#{@oauth_hsh_tw["network_id"]}&data[handle]=#{@oauth_hsh_tw["handle"]}", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}"}).to_return(:status => 200, :body => "#{tw_resp}", :headers => {})
            get :profile, format: :json

            rrc(200)
            json["status"].should     == 1
            json["data"].class.should == String
            json["data"].should == tw_resp
        end

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "data[token]=#{@oauth_hsh_tw["token"]}&data[secret]=#{@oauth_hsh_tw["secret"]}&data[network_id]=#{@oauth_hsh_tw["network_id"]}&data[handle]=#{@oauth_hsh_tw["handle"]}", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}"}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :profile, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end
    end

    describe :create do
        let(:tw_resp) { [{"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" },{"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" }].to_json }
        let(:route) { "http://qam.itson.me/api/twitter/mention" }

        it_should_behave_like("token authenticated", :post, :create)
        it_should_behave_like("proxy_auth_required", :post, :create)

        it "should return 407 Proxy Authentication Required when Oauth keys have expired" do
            stub_request(:post, route).with(:body => "data[token]=#{@oauth_hsh_tw["token"]}&data[secret]=#{@oauth_hsh_tw["secret"]}&data[network_id]=#{@oauth_hsh_tw["network_id"]}&data[handle]=#{@oauth_hsh_tw["handle"]}", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}"}).to_return(:status => 407, :body => "", :headers => {})
            request.env["HTTP_TKN"] = "USER_TOKEN"
            get :create, format: :json
            rrc(407)
            json["status"].should == 0
            json["data"].should   == "-1001"
            json["msg"].should    == "Proxy Authentication Required"
        end
    end

end