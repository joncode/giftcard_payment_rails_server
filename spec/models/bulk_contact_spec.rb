require 'spec_helper'

describe BulkContact do

    before(:each)do
        @current_user = FactoryGirl.create(:user)
        @hsh = { "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"], "phone" => [ "3102974545", "6467586473"], "twitter" => [ "2i134o1234123"], "facebook" => [ "23g2381d103dy1"] }, "22" => { "first_name" => "Jenifer" ,"last_name" => "Bowie", "email" => [ "jenny@facebook.com"], "phone" => ["7824657878"]}}
    end

    it "should save contacts in one upload" do
        BulkContact.create(data: @hsh, user_id: @current_user.id)
        bcs = BulkContact.find_by(user_id: @current_user.id)
        bcs.data.should == @hsh
    end
end
