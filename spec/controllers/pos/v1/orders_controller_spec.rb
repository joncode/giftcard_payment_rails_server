require 'spec_helper'

describe Pos::V1::OrdersController do

    describe :create do

        before(:each) do
            Redeem.delete_all
            Gift.delete_all
            user     = FactoryGirl.create(:user)
            provider = FactoryGirl.create(:provider, pos_merchant_id: 1233)
            @gift     = FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name, status: 'open', provider_id: provider.id)
            @gift.notify
            user = NEXT_GEN_USER
            pw   = NEXT_GEN_PASS
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
        end

        it "should return 404 not found for bad pos_mechant_id" do
            post :create, format: :json, data: {"pos_merchant_id" => 1234, "ticket_value" => "13.99", "redeem_code" => @gift.token, "server_code" => "john"}
            rrc(404)
            json["status"].should == 0
            json["data"].should   == 'Not Found'
        end

        it "should have process the request" do
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @gift.token, "server_code" => "john"}
            rrc(200)
        end

        it "should accept redeem code as string" do
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @gift.token.to_s, "server_code" => "john"}
            rrc(200)
        end

        it "requires http basic authentication" do
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @gift.token, "server_code" => "john"}
            rrc(200)
        end

        it "returns 401 unauthorized if http basic authentication fails" do
            user = 'dhh'
            pw   = 'secret'
            request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user,pw)
            post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @gift.token, "server_code" => "john"}
            rrc(401)
        end

        context :bad_request do
            it "should be successful" do
                post :create, format: :json, data: {"redeem_code" => @gift.token, "pos_merchant_id" => 1233}
                rrc(200)
            end

            it "reject no data key " do
                post :create, format: :json, data: {}
                rrc(400)
            end

            it "reject wrong key " do
                post :create, format: :json, data: {"redeem_code" => @gift.token, "pos_merchant_id" => nil, "wrong" => "params"}
                rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233,"redeem_code" => @gift.token, "ticket_item_ids" => [ 1245, 17235, 1234 ], "server_code" => "john"}
                # rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "ticket_item_ids" => [ 1245, 17235, 1234 ], "server_code" => "john"}
                # rrc(400)
                # post :create, format: :json, data: {"pos_merchant_id" => 1233, "ticket_value" => "13.99", "redeem_code" => @gift.token, "ticket_item_ids" => [ 1245, 17235, 1234 ]}
                # rrc(400)
            end

        end

        it "should be successful" do
            post :create, format: :json, data: {"redeem_code" => @gift.token, "pos_merchant_id" => 1233}
            rrc(200)
            json["status"].should == 1
            json["data"].should == { "voucher_value" => @gift.value }
        end

        it "can't find gift from redeem_code" do
            post :create, format: :json, data: {"redeem_code" => "12345", "pos_merchant_id" => 1233}
            rrc(404)
            json["status"].should == 0
            json["data"].should == "Error - Gift Conﬁrmation No. is not valid."
        end

        it "gift has already been redeemed" do
            @gift.redeem_gift
            @gift.status.should == 'redeemed'
            post :create, format: :json, data: {"redeem_code" => @gift.token, "pos_merchant_id" => 1233}
            rrc(422)
            json["status"].should == 0
            json["data"].should == "Gift #{@gift.token} is already redeemed"
        end

        context "pos request " do

            it "should create ditto with successful request" do
                post :create, format: :json, data: {"redeem_code" => @gift.token, "pos_merchant_id" => 1233}
                rrc(200)
                ditto = Ditto.last
                ditto.response_json.should == { 'request'  => { "redeem_code" => @gift.token, 'pos_merchant_id' => 1233 },
                                                'response' => { :status => 1, :data => { 'voucher_value'=>'100' } } }.to_json
                ditto.status.should        == 200
                ditto.cat.should           == 1000
                ditto.notable_id.should    == @gift.id
                ditto.notable_type.should  == "Gift"
            end

            it "should create ditto with bad request (that has passed authentication)" do
                post :create, format: :json, data: {"redeem_code" => "abcde", "pos_merchant_id" => 1233}
                rrc(404)
                ditto = Ditto.last
                ditto.response_json.should == { 'request' => { 'redeem_code' => 'abcde', 'pos_merchant_id' => 1233 },
                                                'response' => { :status => 0, :data => 'Error - Gift Conﬁrmation No. is not valid.' }}.to_json
                ditto.status.should        == 404
                ditto.cat.should           == 1000
                ditto.notable_id.should    == nil
                ditto.notable_type.should  == "Gift"
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
