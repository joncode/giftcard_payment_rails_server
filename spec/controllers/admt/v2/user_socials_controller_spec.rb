# require 'spec_helper'

# describe Admt::V2::UserSocialsController do

#     before(:each) do
#         User.delete_all
#          # should require valid admin credentials in every spec
#         FactoryGirl.create(:admin_user, remember_token: "Token")
#         request.env["HTTP_TKN"] = "Token"
#     end

#     describe :create do

#         it_should_behave_like("token authenticated", :post, :create)

#         let(:user) { FactoryGirl.create(:user) }

#         it "should require user_social_params" do
#             post :create, format: :json, data: "not a hash"
#             rrc(400)
#             post :create, format: :json, data: nil
#             rrc(400)
#             post :create, format: :json
#             rrc(400)
#             post :create, format: :json, data: { "type_of" => "email", "identifier" => "bob@email.com"}
#             rrc(200)
#         end

#         it "should not update attributes that are not allowed or dont exist" do
#             hsh = { "house" => "chill" }
#             post :create, format: :json, data: hsh
#             rrc(400)
#         end

#         it "should return success msg when success" do
#             post :create, format: :json, data: {"user_id" => user.id, "type_of" => "email", "identifier" => "newemail@email.com"}
#             json["status"].should == 1
#             json["data"].should include({"user_id" => user.id, "type_of" => "email", "identifier" => "newemail@email.com"})
#         end

#         it "should return validation errors" do
#             post :create, format: :json, data: { "identifier" => "" }
#             json["status"].should == 0
#             json["data"].class.should   == Hash
#         end

#         it "should create the user social in database" do
#             post :create, format: :json, data: {"user_id" => user.id, "type_of" => "email", "identifier" => "newemail@email.com"}
#             new_user_social = UserSocial.last
#             new_user_social.user_id.should == user.id
#             new_user_social.type_of.should == "email"
#             new_user_social.identifier.should == "newemail@email.com"
#         end

#         it "should not create the user social in database if email already exists" do
#             existing_email = FactoryGirl.create(:user_social, type_of: "email", identifier: "legacy@email.com", active: true )
#             post :create, format: :json, data: {"user_id" => user.id, "type_of" => "email", "identifier" => "legacy@email.com"}
#             json["status"].should == 0
#             json["data"].class.should   == Hash
#         end

#         it "should not create the user social in database if phone already exists" do
#             existing_email = FactoryGirl.create(:user_social, type_of: "phone", identifier: "2222222222", active: true )
#             post :create, format: :json, data: {"user_id" => user.id, "type_of" => "phone", "identifier" => "2222222222"}
#             json["status"].should == 0
#             json["data"].class.should   == Hash
#         end
#     end

#     describe :update do

#         it_should_behave_like("token authenticated", :put, :update, id: 1)

#         before do
#         	User.delete_all
#         	@user = FactoryGirl.create(:user)
#         end

#         it "should deactivate user social" do
#             updated_user_social = UserSocial.unscoped.find_by(user_id: @user.id)
#             updated_user_social.active.should   be_true
#             put :update, id: updated_user_social.id, format: :json
#             updated_user_social.reload
#             updated_user_social.active.should   be_false
#         end

#         it "should return success msg when success" do
#             updated_user_social = UserSocial.unscoped.find_by(user_id: @user.id)
#             put :update, id: updated_user_social.id, format: :json
#             rrc(200)
#             json["status"].should == 1
#             json["data"].should include({"identifier" => updated_user_social.identifier})
#         end

#         it "should return failure msg when user not found" do
#             put :update, id: 23, format: :json
#             rrc(404)
#         end

#     end
# end
