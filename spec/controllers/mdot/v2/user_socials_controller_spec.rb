require 'spec_helper'

describe Mdot::V2::UserSocialsController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
        end
    end

    # describe :destroy do

    #     it_should_behave_like("token authenticated", :delete, :destroy)

    #     it "should return user ID on success" do
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, identifier: @user.email, type: "email"
    #         rrc(200)
    #         json["status"].should == 1
    #         json["data"].should   == @user.id
    #         delete :destroy, format: :json, identifier: @user.phone, type: "phone"
    #         rrc(200)
    #         json["status"].should == 1
    #         json["data"].should   == @user.id
    #         delete :destroy, format: :json, identifier: @user.facebook_id, type: "facebook_id"
    #         rrc(200)
    #         json["status"].should == 1
    #         json["data"].should   == @user.id
    #         delete :destroy, format: :json, identifier: @user.twitter, type: "twitter"
    #         rrc(200)
    #         json["status"].should == 1
    #         json["data"].should   == @user.id
    #     end

    #     it "should deActivate the user social in the database" do
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         delete :destroy, format: :json, identifier: @user.email, type: "email"
    #         rrc(200)
    #         UserSocial.unscoped.where(identifier: @user.email).first.active.should be_false
    #         delete :destroy, format: :json, identifier: @user.phone, type: "phone"
    #         rrc(200)
    #         UserSocial.unscoped.where(identifier: @user.phone).first.active.should be_false
    #         delete :destroy, format: :json, identifier: @user.facebook_id, type: "facebook_id"
    #         rrc(200)
    #         UserSocial.unscoped.where(identifier: @user.facebook_id).first.active.should be_false
    #         delete :destroy, format: :json, identifier: @user.twitter, type: "twitter"
    #         rrc(200)
    #         UserSocial.unscoped.where(identifier: @user.twitter).first.active.should be_false
    #     end

    #     it "should return 404 with no ID or wrong ID" do
    #         request.env["HTTP_TKN"] = "USER_TOKEN"
    #         user2 = FactoryGirl.create(:user, email: "notthis@no.com", phone: "9879887878")
    #         delete :destroy, format: :json, identifier: user2.email, type: "email"
    #         rrc(404)
    #         delete :destroy, format: :json, identifier: user2.phone, type: "phone"
    #         rrc(404)
    #     end

    # end

end