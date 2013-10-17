require 'spec_helper'

describe Admt::V2::UsersController do

    # describe "giftsdeactivate" do

    #     it "should not allow unauthenticated access" do
    #         request.env["HTTP_TKN"] = "No_Entrance"
    #         post 'deactivate', format: :json
    #         response.response_code.should == 401
    #     end

    #     it "should deactivate the gift" do
    #         gift = FactoryGirl.create(:gift_no_association)
    #         post :deactivate, format: :json
    #         new_gift = Gift.find gift.id
    #         new_gift.active.should be_false
    #     end

    # end

    before(:each) do
        User.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe "#deactivate" do

        it "should not allow unauthenticated access" do
            request.env["HTTP_TKN"] = "No_Entrance"
            put :deactivate, id: 1, format: :json
            response.response_code.should == 401
        end

        it "should permanent deactivate user " do
            user = FactoryGirl.create(:user)
            post :deactivate, id: user.id, format: :json
            deactivated_user = User.unscoped.find(user.id)
            deactivated_user.active.should          be_false
            deactivated_user.perm_deactive.should   be_true
            deactivated_user.phone.should           be_nil
            deactivated_user.facebook_id.should     be_nil
            deactivated_user.twitter.should         be_nil
            user_socials = UserSocial.where(user_id: user.id)
            puts user_socials.inspect
            user_socials.count.should == 0
        end

    end

end

    # def permanently_deactivate
    #     self.active        = false
    #     self.phone         = nil
    #     self.email         = "#{self.email}xxx"
    #     self.facebook_id   = nil
    #     self.twitter       = nil
    #     self.perm_deactive = true
    #     UserSocial.deactivate_all self
    #     save
    # end