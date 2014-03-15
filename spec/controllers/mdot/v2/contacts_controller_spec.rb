require 'spec_helper'

describe Mdot::V2::ContactsController do

    before(:each) do
        unless @user = User.find_by(remember_token: "USER_TOKEN")
            @user = FactoryGirl.create(:user)
            @user.update_attribute(:remember_token, "USER_TOKEN")
            @hsh = { "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"], "phone" => [ "3102974545", "6467586473"], "twitter" => [ "2i134o1234123"], "facebook" => [ "23g2381d103dy1"] }, "22" => { "first_name" => "Jenifer" ,"last_name" => "Bowie", "email" => [ "jenny@facebook.com"], "phone" => ["7824657878"]}}
        end
    end

    describe :upload do
        it_should_behave_like("token authenticated", :post, :upload)

        it "should accept a hash of contacts and save to app_contact db" do
            request.env["HTTP_TKN"] = "USER_TOKEN"
            post :upload, format: :json, data: @hsh
            ac = AppContact.where(user_id: @user.id)
            ac.count.should == 8
            rrc(200)
            json["status"].should == 1
        end

    end

end