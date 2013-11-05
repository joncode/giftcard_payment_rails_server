require 'spec_helper'

describe Mdot::V2::SettingsController do

    before(:all) do
        unless user = User.find_by_remember_token("TokenGood")
            user = FactoryGirl.create(:user)
            user.update_attribute(:remember_token, "TokenGood")
        end
    end

    describe :index do
        it_should_behave_like("token authenticated", :get, :index)

        it "should get the users settings and return json" do
            request.env["HTTP_TKN"] = "TokenGood"
            get :index, format: :json
            keys    =  ["email_follow_up", "email_invite", "email_invoice", "email_receiver_new", "email_redeem", "user_id"]
            response.response_code.should == 200
            hsh = json["data"]
            hsh.class.should == Hash
            keys.each do |key|
                hsh.has_key?(key).should be_true
            end
        end

        it "should return 404 not found for no settings " do

        end
    end

    describe :update do
        it_should_behave_like("token authenticated", :put, :update, id: 1)

    end


end
