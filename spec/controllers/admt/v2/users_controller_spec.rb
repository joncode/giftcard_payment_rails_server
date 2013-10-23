require 'spec_helper'

describe Admt::V2::UsersController do

    before(:each) do
        User.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe :update do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        let(:user) { FactoryGirl.create(:user) }

        it "should require a valid user_id" do
            destroy_id = user.id
            user.destroy
            put :update, id: destroy_id, format: :json, data: { "first_name" => "JonBoy"}
            response.response_code.should  == 200
            json["status"].should == 0
            json["data"].should   == "App user not found - #{destroy_id}"
        end

        it "should require a update hash" do
            put :update, id: user.id, format: :json, data: "updated data"
            response.response_code.should == 400
            put :update, id: user.id, format: :json, data: nil
            response.response_code.should == 400
            put :update, id: user.id, format: :json
            response.response_code.should == 400
            put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
            response.response_code.should == 200
        end

        it "should return success msg when success" do
            put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
            json["status"].should == 1
            json["data"].should   == "User #{user.id} updated"
        end

        it "should return validation errors" do
            put :update, id: user.id, format: :json, data: { "email" => "" }
            json["status"].should == 0
            json["data"].class.should   == Hash
        end

        {
            first_name: "Ray",
            last_name:  "Davies",
            email: "ray@davies.com",
            phone: "5877437859"
        }.stringify_keys.each do |type_of, value|

            it "should update the user #{type_of} in database" do
                put :update, id: user.id, format: :json, data: { type_of => value }
                new_user = User.last
                new_user.send(type_of).should == value
            end
        end

        it "should not update keys that are not allowed" do
            hsh = { "house" => "chill" }
            put :update, id: user.id, format: :json, data: hsh
            response.response_code.should == 400
        end

    end

    describe :deactivate do

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

        it "should return success msg when success" do
            user = FactoryGirl.create(:user)
            post :deactivate, id: user.id, format: :json
            response.response_code.should == 200
            json["status"].should == 1
            json["data"].should   == "#{user.name} is deactivated"
        end

        xit "should return failure msg when error" do
            user = FactoryGirl.create(:user)
            post :deactivate, id: user.id, format: :json
            response.response_code.should == 200
            json["status"].should       == 0
            json["data"].class.should   == Hash
        end

        it "should return failure msg when user not found" do
            post :deactivate, id: 23, format: :json
            response.response_code.should == 200
            json["status"].should       == 0
            json["data"].should   == "App user not found - 23"
        end

    end

    describe :deactivate_gifts do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                post :deactivate_gifts, id: 10, format: :json
                response.response_code.should == 401
            end

        end

        it "should deactivate all given and received gifts for user" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift_no_association, :giver_id => user.id)
            gift2 = FactoryGirl.create(:gift_no_association, :receiver_id => user.id)
            post :deactivate_gifts, id: user.id, format: :json
            new_gift = Gift.unscoped.find gift.id
            new_gift.active.should be_false
            new_gift2 = Gift.unscoped.find gift.id
            new_gift2.active.should be_false
        end

        it "should return success msg when success" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift_no_association, :giver_id => user.id)
            gift2 = FactoryGirl.create(:gift_no_association, :receiver_id => user.id)
            post :deactivate_gifts, id: user.id, format: :json
            response.response_code.should == 200
            json["status"].should         == 1
            json["data"].should           == "#{user.name} all gifts deactivated"
        end

        xit "should return failure msg when error" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift_no_association, :giver_id => user.id)
            gift2 = FactoryGirl.create(:gift_no_association, :receiver_id => user.id)
            post :deactivate_gifts, id: user.id, format: :json
            response.response_code.should == 200
            json["status"].should         == 0
            json["data"].should           == "Error in batch deactivate gifts"
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