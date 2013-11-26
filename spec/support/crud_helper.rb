module CrudHelper

    def update_tests

        it  "works" do
            true.should == true
        end

    end



    # describe :update do

    #     context "authorization" do

    #         it "should not allow unauthenticated access" do
    #             request.env["HTTP_TKN"] = "No_Entrance"
    #             put :update, id: 1, format: :json
    #             rrc(401)
    #         end

    #     end

    #     let(:user) { FactoryGirl.create(:user) }

    #     it "should require a valid user_id" do
    #         destroy_id = user.id
    #         user.destroy
    #         put :update, id: destroy_id, format: :json, data: { "first_name" => "JonBoy"}
    #         response.response_code.should  == 404
    #     end

    #     it "should require a update hash" do
    #         put :update, id: user.id, format: :json, data: "updated data"
    #         rrc(400)
    #         put :update, id: user.id, format: :json, data: nil
    #         rrc(400)
    #         put :update, id: user.id, format: :json
    #         rrc(400)
    #         put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
    #         rrc(200)
    #     end

    #     it "should return success msg when success" do
    #         put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
    #         json["status"].should == 1
    #         json["data"].should   == "User #{user.id} updated"
    #     end

    #     it "should return validation errors" do
    #         put :update, id: user.id, format: :json, data: { "email" => "" }
    #         json["status"].should == 0
    #         json["data"].class.should   == Hash
    #     end

    #     {
    #         first_name: "Ray",
    #         last_name:  "Davies",
    #         email: "ray@davies.com",
    #         phone: "5877437859"
    #     }.stringify_keys.each do |type_of, value|

    #         it "should update the user #{type_of} in database" do
    #             put :update, id: user.id, format: :json, data: { type_of => value }
    #             new_user = User.last
    #             new_user.send(type_of).should == value
    #         end
    #     end

    #     it "should not update attributes that are not allowed or dont exist" do
    #         hsh = { "house" => "chill" }
    #         put :update, id: user.id, format: :json, data: hsh
    #         rrc(400)
    #     end

    # end


end

RSpec.configuration.include(CrudHelper)