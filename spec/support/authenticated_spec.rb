shared_examples_for "token authenticated" do |verb, route, params|

  it "should not allow unauthenticated access" do
      request.env["HTTP_TKN"] = "No_Entrance"
      puts "-----------#{verb} | #{route} | #{params} ------------"
      send(verb,route, params, format: :json)
      response.response_code.should  == 401
  end

end

  

