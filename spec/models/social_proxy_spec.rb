require 'spec_helper'

describe SocialProxy do

    before(:each) do
        user       = FactoryGirl.create(:user)
        user_oauth = FactoryGirl.create(:oauth, user: user)
        @oauth_hsh_tw = user_oauth.to_proxy
        user_oauth = FactoryGirl.create(:oauth_fb, user: user)
        @oauth_hsh_fb = user_oauth.to_proxy
    end

    it "should require oauth key hsh and network" do
        require_hsh  = @oauth_hsh_tw
        social_proxy = SocialProxy.new(require_hsh)
        social_proxy.valid?.should be_true

        require_hsh  = @oauth_hsh_fb
        social_proxy = SocialProxy.new(require_hsh)
        social_proxy.valid?.should be_true
    end

    context "friends" do

        context "facebook" do

            let(:fb_friends) { [{"network_id"=>"27428352","network"=>"facebook","name"=>"Taylor Addison","photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg","birthday"=>"10/05/1987"}].to_json}
            let(:route) { "http://qam.itson.me/api/facebook/friends" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_friends}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 200
                social_proxy.data.should   == JSON.parse(fb_friends)
                social_proxy.msg.should    == nil

            end

            it "should get array of facebook friends from HTTP" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_friends}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                data = social_proxy.data
                data.class.should   == Array
                hsh = data.first
                fb_keys = ["network_id", "network", "name", "photo", "birthday"]
                compare_keys(hsh, fb_keys)
            end
            
        end

        context "twitter" do

            let(:tw_friends) { [{"network_id"=>"27428352","network"=>"twitter","name"=>"Taylor Addison","handle"=>"taylor.addison1","photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json}
            let(:route) { "http://qam.itson.me/api/twitter/friends" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_friends}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                social_proxy.status.should == 200
                social_proxy.data.should   == JSON.parse(tw_friends)
                social_proxy.msg.should    == nil

            end

            it "should get array of facebook friends from HTTP" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_friends}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.friends
                data = social_proxy.data
                data.class.should   == Array
                hsh = data.first
                fb_keys = ["network_id", "network", "name", "handle", "photo"]
                compare_keys(hsh, fb_keys)
            end
        end
    end

    context "create_post" do

        context "facebook" do
            let(:fb_resp) { [{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"},{ "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}].to_json }
            let(:route) { "http://qam.itson.me/api/facebook/story" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_fb["token"]}\",\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_fb["token"]}\",\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_fb["token"]}\",\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_resp}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 200
                social_proxy.data.should   == fb_resp
                social_proxy.msg.should    == nil

            end

            it "should get array of facebook friends from HTTP" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_fb["token"]}\",\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_resp}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                data = JSON.parse social_proxy.data
                data.class.should   == Array
                hsh = data.first
                data.count.should == 2
                fb_keys = ["network_id",  "name", "photo", "birthday"]
                compare_keys(hsh, fb_keys)
            end
        end

        context "twitter" do
            let(:tw_resp) { [{"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" },{"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" }].to_json }
            let(:route) { "http://qam.itson.me/api/twitter/mention" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\",\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"handle\":\"#{@oauth_hsh_tw["handle"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\",\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"handle\":\"#{@oauth_hsh_tw["handle"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\",\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"handle\":\"#{@oauth_hsh_tw["handle"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_resp}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                social_proxy.status.should == 200
                social_proxy.data.should   == tw_resp
                social_proxy.msg.should    == nil

            end

            it "should get array of facebook friends from HTTP" do
                stub_request(:post, route).with(:body => "{\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\",\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"handle\":\"#{@oauth_hsh_tw["handle"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_resp}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.create_post
                data = JSON.parse social_proxy.data
                data.class.should   == Array
                hsh = data.first
                data.count.should == 2
                fb_keys = ["network_id", "name", "handle", "photo"]
                compare_keys(hsh, fb_keys)
            end
        end
    end

    context "profile" do

        context "facebook" do
            let(:fb_resp) { { "birthday"  =>"10/05/1987", "network_id"=>"27428352", "name" =>"Taylor Addison", "photo" =>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg"}.to_json }
            let(:route) { "http://qam.itson.me/api/facebook/profile" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_resp}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 200
                social_proxy.data.should   == fb_resp
                social_proxy.msg.should    == nil

            end

            it "should get json hash of facebook user profile info" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_fb["network_id"]}\",\"token\":\"#{@oauth_hsh_fb["token"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{fb_resp}", :headers => {})
                require_hsh  = @oauth_hsh_fb
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                data = JSON.parse social_proxy.data
                data.class.should   == Hash
                fb_keys = ["network_id", "name", "photo", "birthday"]
                compare_keys(data, fb_keys)
            end
        end

        context "twitter" do
            let(:tw_resp) { {"network_id"=> "112745132", "name"=> "stewart christensen", "handle"=> "stewart_ch", "photo"=> "http://pbs.twimg.com/profile_images/1798349717/2_normal.jpg" }.to_json }
            let(:route) { "http://qam.itson.me/api/twitter/account" }

            it "should reply 401 - cannot reach server when auth fails" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 401, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 401
                social_proxy.data.should   == nil
                social_proxy.msg.should    == "Unauthorized"
            end

            it "should respond 407 when oauth keys are expired" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 407, :body => "", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 407
                social_proxy.data.should   == -1001
                social_proxy.msg.should    == "Proxy Authentication Required"

            end

            it "should set status to 200 when successful" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_resp}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                social_proxy.status.should == 200
                social_proxy.data.should   == tw_resp
                social_proxy.msg.should    == nil

            end

            it "should get json hash of twitter user profile info" do
                stub_request(:post, route).with(:body => "{\"network_id\":\"#{@oauth_hsh_tw["network_id"]}\",\"token\":\"#{@oauth_hsh_tw["token"]}\",\"secret\":\"#{@oauth_hsh_tw["secret"]}\"}", :headers => {'Accept'=>'text/json', 'Authorization'=>"#{SOCIAL_PROXY_TOKEN}", 'Content-Type'=>'application/json'}).to_return(:status => 200, :body => "#{tw_resp}", :headers => {})
                require_hsh  = @oauth_hsh_tw
                social_proxy = SocialProxy.new(require_hsh)
                social_proxy.profile
                data = JSON.parse social_proxy.data
                data.class.should   == Hash
                tw_keys = ["network_id", "handle", "name", "photo"]
                compare_keys(data, tw_keys)
            end
        end
    end
end