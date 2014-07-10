require 'spec_helper'

describe Pos::V1::OrdersController do

    describe :create do

        before(:each) do
            user = FactoryGirl.create(:user)
            provider = FactoryGirl.create(:provider, pos_merchant_id: 1233)
            gift = FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name, status: 'open', provider_id: provider.id)
            @redeem = Redeem.find_or_create_with_gift(gift)
            user = NEXT_GEN_USER
            pw   = NEXT_GEN_PASS
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
        end

        it "should have a create route" do
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @redeem.redeem_code, "server_code" => "john"}
        end

        it "requires http basic authentication" do
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @redeem.redeem_code, "server_code" => "john"}
            rrc(200)
        end

        it "returns 401 unauthorized if http basic authentication fails" do
            user = 'dhh'
            pw   = 'secret'
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @redeem.redeem_code, "server_code" => "john"}
            rrc(401)
        end

        context :bad_request do
            it "should be successful" do
                post :create, format: :json, data: {"redeem_code" => @redeem.redeem_code, "pos_merchant_id" => 1233}
                rrc(200)
            end

            it "reject no data key " do
                post :create, format: :json, data: {}
                rrc(400)
            end

            it "reject wrong key " do
                post :create, format: :json, data: {"redeem_code" => @redeem.redeem_code, "pos_merchant_id" => nil, "wrong" => "params"}
                rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233,"redeem_code" => @redeem.redeem_code, "ticket_item_ids" => [ 1245, 17235, 1234 ], "server_code" => "john"}
                # rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "ticket_item_ids" => [ 1245, 17235, 1234 ], "server_code" => "john"}
                # rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @redeem.redeem_code, "ticket_item_ids" => [ 1245, 17235, 1234 ]}
                # rrc(400)
            end

        end

        context :data_not_found do
            it "should be successful" do
                post :create, format: :json, data: {"redeem_code" => @redeem.redeem_code, "pos_merchant_id" => 1233}
                rrc(200)
                json["status"].should == 1
                json["data"].should == { "voucher_value" => @redeem.gift.value }
            end
            it "can't find redeem from redeem_code" do
                post :create, format: :json, data: {"redeem_code" => "12345", "pos_merchant_id" => 1233}
                rrc(404)
                json["status"].should == 0
                json["data"].should == "Error - Gift Conﬁrmation No. is not valid."
            end
            it "can't find redeem from redeem_code" do
                post :create, format: :json, data: {"redeem_code" => @redeem.redeem_code, "pos_merchant_id" => 0000}
                rrc(404)
                json["status"].should == 0
                json["data"].should == "Error - Gift Conﬁrmation No. is not valid."
            end
        end



        it "gets the redeem / gift with the pos_merchant_id & redeem_code" do
            # redeem.include(:gift).where(pos_merchant_id: 1233, redeem_code: 1234)
            # why am i getting the redeem off th gift when i have it already ?
            # gift must be notified - that code - can i redeem this method
            # make error messages
            # create the order - generate success messages
        end
    end
end

# 200 ok , 400 bad request , 404 not found

# { status: 1, data: { voucher_value: “13.99” }}
# {status: 0, data: { error: “error message to screen” }}
