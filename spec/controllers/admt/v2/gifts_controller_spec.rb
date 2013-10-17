require 'spec_helper'

describe Admt::V2::GiftsController do

    before(:each) do
        Gift.delete_all

         # should require valid admin credentials in every spec
        unless admin_user = AdminUser.find_by_remember_token("Token")
            FactoryGirl.create(:admin_user, remember_token: "Token")
        end
        request.env["HTTP_TKN"] = "Token"
    end

    describe "update" do
        gift = FactoryGirl.create(:gift_no_association)
        post :update, id: gift.id, format: :json, data: "updated data"
        new_gift = Gift.find gift.id
        new_gift.active.should be_false
    end

    describe "refund" do
        gift = FactoryGirl.create(:gift_no_association)
        post :refund, id: gift.id, format: :json, data: "??"
        new_gift = Gift.find gift.id
        new_gift.pay_stat.should == "refunded"
        new_gift.status.should   == gift.status
    end

    describe "refund_cancel" do
        gift = FactoryGirl.create(:gift_no_association)
        post :refund_cancel, id: gift.id, format: :json, data: "??"
        new_gift = Gift.find gift.id
        new_gift.pay_stat.should == "refunded"
        new_gift.status.should   == "cancel"
    end

    describe "deactivate" do
        gift = FactoryGirl.create(:gift_no_association)
        post :deactivate, id: gift.id, format: :json
        new_gift = Gift.find gift.id
        new_gift.active.should be_false
    end

end