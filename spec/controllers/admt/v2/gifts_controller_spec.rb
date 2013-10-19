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

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :update, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should not allow unauthenticated access" do
            request.env["HTTP_TKN"] = "No_Entrance"
            put :update, id: 1, format: :json
            response.response_code.should == 401
        end

        xit "should update the gift information" do
            gift = FactoryGirl.create(:gift_no_association)
            put :update, id: gift.id, format: :json, data: "updated data"
            new_gift = Gift.find gift.id

        end

    end

    describe "refund" do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :refund, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, pay_stat: 'charged', status: 'open') }


            it "should set the gift 'pay_stat' to 'refunded' and not change the gift status" do
                post :refund, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should == "refunded"
                new_gift.status.should   == gift.status
            end

        end
    end

    describe "refund_cancel" do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :refund_cancel, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        context "behavior" do

            let(:gift) { FactoryGirl.create(:gift_no_association, pay_stat: 'charged', status: 'open') }

            it "should set the gift 'pay_stat' to 'refunded' " do
                post :refund_cancel, id: gift.id, format: :json
                new_gift = Gift.find gift.id
                new_gift.pay_stat.should == "refunded"
                new_gift.status.should   == 'cancel'
            end

        end
    end

    describe "deactivate" do

        context "authorization" do

            it "should not allow unauthenticated access" do
                request.env["HTTP_TKN"] = "No_Entrance"
                put :deactivate, id: 1, format: :json
                response.response_code.should == 401
            end

        end

        it "should route correct" do
            expect(:post => "admt/v2/users/1/gifts/deactivate_all.json").to route_to(
              :controller => "admt/v2/gifts",
              :action => "deactivate_all",
              :user_id => "1",
              :format => "json"
            )
        end

        # it "should not allow unauthenticated access" do
        #     request.env["HTTP_TKN"] = "No_Entrance"
        #     post 'deactivate', format: :json
        #     response.response_code.should == 401
        # end

        # it "should deactivate the gift" do
        #     gift = FactoryGirl.create(:gift_no_association)
        #     post :deactivate, format: :json
        #     new_gift = Gift.find gift.id
        #     new_gift.active.should be_false
        # end

    end

end
























