require 'spec_helper'

describe Admt::V2::UsersController do

    before(:each) do
        User.delete_all

         # should require valid admin credentials in every spec
        FactoryGirl.create(:admin_user, remember_token: "Token")
        request.env["HTTP_TKN"] = "Token"
    end

    describe :update do

        it_should_behave_like("token authenticated", :put, :update, id: 1)

        let(:user) { FactoryGirl.create(:user) }

        it "should require a valid user_id" do
            destroy_id = user.id
            user.destroy
            put :update, id: destroy_id, format: :json, data: { "first_name" => "JonBoy"}
            response.response_code.should  == 404
        end

        it "should require a update hash" do
            put :update, id: user.id, format: :json, data: "updated data"
            response.response_code.should == 400
            put :update, id: user.id, format: :json, data: nil
            response.response_code.should == 400
            put :update, id: user.id, format: :json
            response.response_code.should == 400
            put :update, id: user.id, format: :json, data: { "first_name" => "Steve"}
            rrc(200)
        end

        it "should not update attributes that are not allowed or dont exist" do
            hsh = { "house" => "chill" }
            put :update, id: user.id, format: :json, data: hsh
            response.response_code.should == 400
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
    end

    describe :deactivate do

        it_should_behave_like("token authenticated", :post, :deactivate, id: 1)

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
            rrc(200)
            json["status"].should == 1
            json["data"].should   == "#{user.name} is deactivated"
        end

        xit "should return failure msg when error" do
            user = FactoryGirl.create(:user)
            post :deactivate, id: user.id, format: :json
            rrc(200)
            json["status"].should       == 0
            json["data"].class.should   == Hash
        end

        it "should return failure msg when user not found" do
            post :deactivate, id: 23, format: :json
            rrc(200)
            json["status"].should       == 0
            json["data"].should   == "App user not found - 23"
        end

    end

    describe :suspend do

        it_should_behave_like("token authenticated", :post, :suspend, id: 1)

        it "should suspend user " do
            user = FactoryGirl.create(:user)
            post :suspend, id: user.id, format: :json
            suspended_user = User.unscoped.find(user.id)
            suspended_user.active.should          be_false
            suspended_user.perm_deactive.should   be_false
            user.user_socials.each do |social|
                social.active.should be_false
            end
        end

        it "should suspend active users" do
            user = FactoryGirl.create(:user)
            user.active.should == true
            post :suspend, id: user.id, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].should   == "#{user.name} is now suspended"
            user.reload
            user.active.should == false
        end

        it "should unsuspend inactive users" do
            user = FactoryGirl.create :user, { active: false }
            user.active.should == false
            post :suspend, id: user.id, format: :json
            rrc(200)
            json["status"].should == 1
            json["data"].should   == "#{user.name} is now unsuspended"
            user.reload
            user.active.should == true
        end

        it "should return failure msg when user not found" do
            post :suspend, id: 23, format: :json
            rrc(200)
            json["status"].should       == 0
            json["data"].should   == "App user not found - 23"
        end

    end

    describe :deactivate_gifts do

        it_should_behave_like("token authenticated", :post, :deactivate_gifts, id: 1)

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
            rrc(200)
            json["status"].should         == 1
            json["data"].should           == "#{user.name} all gifts deactivated"
        end

        xit "should return failure msg when error" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create(:gift_no_association, :giver_id => user.id)
            gift2 = FactoryGirl.create(:gift_no_association, :receiver_id => user.id)
            post :deactivate_gifts, id: user.id, format: :json
            rrc(200)
            json["status"].should         == 0
            json["data"].should           == "Error in batch deactivate gifts"
        end

    end

end
