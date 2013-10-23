require 'spec_helper'

describe Admt::V2::GiftsController do

    before(:each) do
        Gift.delete_all

        unless admin_user = AdminUser.find_by_remember_token("Token")
            FactoryGirl.create(:admin_user, remember_token: "Token")
        end
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

        let(:gift) { FactoryGirl.create(:gift_no_association) }

        it "should require a valid gift_id" do
            destroy_id = gift.id
            gift.destroy
            put :update, id: destroy_id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            response.response_code.should  == 200
            json["status"].should == 0
            json["data"].should   == "Gift not found - #{destroy_id}"
        end

        it "should require a update hash" do
            put :update, id: gift.id, format: :json, data: "updated data"
            response.response_code.should == 400
            put :update, id: gift.id, format: :json, data: nil
            response.response_code.should == 400
            put :update, id: gift.id, format: :json
            response.response_code.should == 400
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            response.response_code.should == 200
        end

        it "should return success msg when success" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "Jon Goodness"}
            json["status"].should == 1
            json["data"].should   == "#{gift.id} updated"
        end

        it "should return validation errors" do
            put :update, id: gift.id, format: :json, data: { "receiver_name" => "" }
            json["status"].should == 0
            json["data"].class.should   == Hash
        end

        {
            receiver_name: "Ray Davies",
            receiver_email: "ray@davies.com",
            receiver_phone: "587-743-7859"
        }.stringify_keys.each do |type_of, value|

            it "should update the gift information in database" do
                put :update, id: gift.id, format: :json, data: { type_of => value }
                new_gift = Gift.last
                new_gift.send(type_of).should == value

            end
        end

        it "should not update attributes that are not allowed or dont exist" do
            hsh = { "house" => "chill" }
            put :update, id: gift.id, format: :json, data: hsh
            response.response_code.should == 400
        end

    end

    describe :refund do

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

    describe :refund_cancel do

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

end
























