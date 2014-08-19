require 'spec_helper'

describe Web::V3::GiftsController do

    before(:each) do
    	@user     = FactoryGirl.create :user
    	other1    = FactoryGirl.create :user
    	other2    = FactoryGirl.create :user
        @provider = FactoryGirl.create :provider
    	3.times { FactoryGirl.create :gift, giver: other1, receiver_name: @user.name, receiver_id: @user.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: @user, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
    	3.times { FactoryGirl.create :gift, giver: other1, receiver_name: other2.name, receiver_id: other2.id, provider: @provider}
        request.headers["HTTP_X_AUTH_TOKEN"] = @user.remember_token
    end

    it "should return the correct gifts for the user" do
        get :index, format: :json
        rrc(200)
        json["data"].count.should == 6
    end

end
