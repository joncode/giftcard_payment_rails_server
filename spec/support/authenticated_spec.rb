shared_examples_for "token authenticated" do |verb, route, params|

    it "should not allow unauthenticated access" do
        request.env["HTTP_TKN"] = "No_Entrance"
        puts "-----------#{verb} | #{route} | #{params} ------------"
        send(verb,route, params, format: :json)
        response.response_code.should  == 401
    end

end

shared_examples_for "proxy_auth_required" do |verb, route|

    it "should return 407 when oauth credentials are missing" do
        user = FactoryGirl.create(:user)
        user.update(remember_token: "OAUTH_TOKEN")
        request.env["HTTP_TKN"] = "OAUTH_TOKEN"
        puts "-----------#{verb} | #{route}  ------------"
        send(verb,route, format: :json)
        response.response_code.should  == 407
        json["status"].should == 0
        json["data"].should   == "-1001"
        json["msg"].should    == "Proxy Authentication Required"
    end

end



