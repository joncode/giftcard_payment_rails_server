shared_examples_for "sanitize update" do |verb, route, params|

    it "should require a valid id" do
        destroy_id = user.id
        user.destroy
        put :update, id: destroy_id, format: :json, data: { "first_name" => "JonBoy"}
        send(verb, route)
        response.response_code.should  == 404
    end

    it "should require a update hash" do
        put :update, id: user.id, format: :json, data: "updated data"
        rrc(400)
        put :update, id: user.id, format: :json, data: nil
        rrc(400)
        put :update, id: user.id, format: :json
        rrc(400)
        put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
        rrc(200)
    end
    
    it "should not update attributes that are not allowed or dont exist" do
        hsh = { "house" => "chill" }
        put :update, id: user.id, format: :json, data: hsh
        rrc(400)
    end

end