require 'spec_helper'

describe HttpModel do

    let(:route) { "http://m.itson.me/api/facebook/friends" }
    let(:token) { "18376451978234" }
    let(:fb_friends) { [{"network_id"=>"27428352","network"=>"facebook","name"=>"Taylor Addison","handle"=>"taylor.addison1","photo"=>"https://fbcdn-profile-a.akamaihd.net/hprofile-ak-prn2/t5/1119714_27428352_13343146_q.jpg","birthday"=>"10/05/1987"}].to_json}
    class HttpModelTester
        include HttpModel
    end

    http_verbs = [:post, :put]

    http_verbs.each do |verb|

        describe "#{verb}" do

            it "should require - route / token" do
                hmt  = HttpModelTester.new
                resp = hmt.send(verb, token: nil, route: nil)
                resp.should == { "status" => 0, "data" => "internal error"}
            end

            it "should return failure message if no token" do
                hmt  = HttpModelTester.new
                resp = hmt.send(verb, token: nil, route: route)
                resp.should == { "status" => 0, "data" => "internal error"}
            end

            it "should return failure message if no route" do
                hmt  = HttpModelTester.new
                resp = hmt.send(verb, token: token, route: nil)
                resp.should == { "status" => 0, "data" => "internal error"}
            end

            it "should return success message with no params" do
                stub_request(verb, route).to_return(:status => 200, :body => "#{fb_friends}", :headers => {})
                hmt  = HttpModelTester.new
                resp = hmt.send(verb, token: token, route: route)
                resp.should == {"status"=>200, "data"=>fb_friends}
            end

            it "should return success message if succeeds with params" do
                stub_request(verb, route).with(:body => "data[token]=9q3562341341&data[network]=facebook&data[network_id]=9865465748", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{token}"}).to_return(:status => 200, :body => "#{fb_friends}", :headers => {})
                hmt  = HttpModelTester.new
                oauth = FactoryGirl.create(:oauth_fb)
                params = oauth.to_proxy
                resp = hmt.send(verb, token: token, route: route, params: params)
                resp.should == {"status"=>200, "data"=>fb_friends}
            end

            it "should return 407 proxy authentication required" do
                stub_request(verb, route).with(:body => "data[token]=9q3562341341&data[network]=facebook&data[network_id]=9865465748", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{token}"}).to_return(:status => 407, :body => "", :headers => {})
                hmt  = HttpModelTester.new
                oauth = FactoryGirl.create(:oauth_fb)
                params = oauth.to_proxy
                resp = hmt.send(verb, token: token, route: route, params: params)
                resp.should == {"status"=>407, "msg"=>"Proxy Authentication Required", "data" => -1001}
            end


            it "should return 401 unauthoritzed" do
                stub_request(verb, route).with(:body => "data[token]=9q3562341341&data[network]=facebook&data[network_id]=9865465748", :headers => {'Accept'=>'application/json', 'Authorization'=>"#{token}"}).to_return(:status => 401, :body => "", :headers => {})
                hmt  = HttpModelTester.new
                oauth = FactoryGirl.create(:oauth_fb)
                params = oauth.to_proxy
                resp = hmt.send(verb, token: token, route: route, params: params)
                resp.should == {"status"=>401, "msg"=> "Unauthorized"}
            end
        end
    end

end