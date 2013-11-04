shared_examples_for "token authenticated" do |verb, route, params|

  it "should not allow unauthenticated access" do
      request.env["HTTP_TKN"] = "No_Entrance"
      puts "-----------#{verb} | #{route} | #{params} ------------"
      send(verb,route, params, format: :json)
      response.response_code.should  == 401
  end

end

shared_examples_for "correct token allowed" do |verb, route, params, token|

  it "should allow authenticated access via header token" do
      request.env["HTTP_TKN"] = token
      puts "----------- #{verb} | #{route} | #{params} | #{token} ------------"
      send(verb,route, params, format: :json)
      response.response_code.should  == 200
  end

end

