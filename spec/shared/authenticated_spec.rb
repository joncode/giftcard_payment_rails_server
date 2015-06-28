

shared_examples_for "token authenticated" do |verb, route, params|

    it "should not allow unauthenticated access" do
        request.env["HTTP_TKN"] = "No_Entrance"
        puts "----------- #{verb.upcase} | :#{route} | #{params} ------------"
        send(verb,route, params, format: :json)
        response.response_code.should  == 401
    end

end

shared_examples_for "client-token authenticated" do |verb, route, params|

    it "should not allow unauthenticated access session token bad" do

        request.env["HTTP_X_AUTH_TOKEN"] = "No_Entrance"
        puts "----------- #{verb} | :#{route} | #{params} ------------"
        send(verb,route, params, format: :json)
        response.response_code.should  == 401
     end

    it "should not allow unauthenticated access with bad :application_key" do

        request.env['HTTP_X_APPLICATION_KEY'] =  'Bad_Company_Key'
        puts "----------- #{verb} | :#{route} | #{params} ------------"
        send(verb,route, params, format: :json)
        response.response_code.should  == 401
    end

    it "should not allow unauthenticated access when session token is not from client" do
        if request.env["HTTP_X_AUTH_TOKEN"] != WWW_TOKEN
            include UserSessionFactory
            include AffiliateFactory
            client = make_partner_client('Client2', 'Tester2')
            user = create_user_with_token "USER_TOKEN", nil
            request.env['HTTP_X_APPLICATION_KEY'] = client.application_key
            request.env["HTTP_X_AUTH_TOKEN"] = "USER_TOKEN"
            puts "----------- #{verb} | :#{route} | #{params} ------------"
            send(verb,route, params, format: :json)
            response.response_code.should  == 401
        end
    end
end

shared_examples_for "proxy_auth_required" do |verb, route|

    it "should return 407 when oauth credentials are missing" do
        user = FactoryGirl.create(:user)
        user = create_user_with_token "OAUTH_TOKEN", user
        request.env["HTTP_TKN"] = "OAUTH_TOKEN"
        puts "-----------#{verb.upcase} | :#{route}  ------------"
        send(verb,route, format: :json)
        response.response_code.should  == 407
        json["status"].should == 0
        json["data"].should   == "-1001"
        json["msg"].should    == "Proxy Authentication Required"
    end

end





