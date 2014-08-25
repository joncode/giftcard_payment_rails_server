require 'spec_helper'

describe PaymentGatewayCim do

    context "charge card" do

        it "should return correct hash" do
            stub_request(
                :post, "https://apitest.authorize.net/xml/v1/request.api"
            ).to_return(
                :status => 200,
                :body => "1,1,1,This transaction has been approved.,000000,Y,2000000001,INV000001,description of transaction,10.95,CC,auth_capture,custId123,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,mark@example.com,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,1.00,0.00,2.00,FALSE,PONUM000001,D18EB6B211FE0BBF556B271FDA6F92EE,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
                :headers => {}
            )
            user = FactoryGirl.create(:user, cim_profile: "11111")
            card = FactoryGirl.create(:card, :user_id => user.id, cim_token: "22222")

            require_hsh = {}
            require_hsh["amount"]             = "100.00"
            require_hsh["unique_id"]          = "first"
            require_hsh["transaction_id"]     = "11111"
            require_hsh["profile_id"]         = user.cim_profile
            require_hsh["payment_profile_id"] = card.cim_token
            paygate_cim = PaymentGatewayCim.new(require_hsh)
            response = paygate_cim.charge
            response["transaction_id"].should == "11111"
            response["resp_json"].should be_present
            response["resp_code"].should be_present
            response["reason_code"].should be_present
            # Add specs to test value of response. 
        end
    end

    context "create profile" do
        it "should return correct hash" do
            stub_request(
                :post, "https://apitest.authorize.net/xml/v1/request.api"
            ).to_return(
                :status => 200,
                :body => "1,1,1,This transaction has been approved.,000000,Y,2000000001,INV000001,description of transaction,10.95,CC,auth_capture,custId123,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,mark@example.com,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,1.00,0.00,2.00,FALSE,PONUM000001,D18EB6B211FE0BBF556B271FDA6F92EE,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
                :headers => {}
            )
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:card, :user_id => user.id)

            response, ditto = PaymentGatewayCim.create_profile(card, "111111", "22222")
            response.class.should == AuthorizeNet::CIM::Response
            ditto.class.should    == Ditto
            # Add specs to test value of response. 
        end
    end

    context "add payment to profile" do
        it "should return correct hash" do
            stub_request(
                :post, "https://apitest.authorize.net/xml/v1/request.api"
            ).to_return(
                :status => 200,
                :body => "1,1,1,This transaction has been approved.,000000,Y,2000000001,INV000001,description of transaction,10.95,CC,auth_capture,custId123,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,mark@example.com,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,1.00,0.00,2.00,FALSE,PONUM000001,D18EB6B211FE0BBF556B271FDA6F92EE,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
                :headers => {}
            )
            user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:card, :user_id => user.id)

            response, ditto = PaymentGatewayCim.add_payment_profile(card, "111111", "22222")
            response.class.should == AuthorizeNet::CIM::Response
            ditto.class.should    == Ditto
            # Add specs to test value of response. 
        end
    end


end
