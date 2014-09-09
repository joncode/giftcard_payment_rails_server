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
            # stub_request(
            #     :post, "https://apitest.authorize.net/xml/v1/request.api"
            # ).to_return(
            #     :status => 200,
            #     :body => "1,1,1,This transaction has been approved.,000000,Y,2000000001,INV000001,description of transaction,10.95,CC,auth_capture,custId123,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,mark@example.com,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,1.00,0.00,2.00,FALSE,PONUM000001,D18EB6B211FE0BBF556B271FDA6F92EE,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
            #     :headers => {}
            # )
            user = FactoryGirl.create(:user)

            stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
            with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <profile>\n    <merchantCustomerId>#{user.obscured_id}</merchantCustomerId>\n  </profile>\n  <validationMode>none</validationMode>\n</createCustomerProfileRequest>\n",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
            to_return(
                :status => 200,
                :body => "1,1,1,This transaction has been approved.,000000,Y,2000000001,INV000001,description of transaction,10.95,CC,auth_capture,custId123,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,000-000-0000,,mark@example.com,John,Doe,,123 Main St.,Bellevue,WA,98004,USA,1.00,0.00,2.00,FALSE,PONUM000001,D18EB6B211FE0BBF556B271FDA6F92EE,M,2,,,,,,,,,,,,,,,,,,,,,,,,,,,,",
                :headers => {}
            )


            response = PaymentGatewayCim.create_customer_profile(user.obscured_id)
            response.class.should == AuthorizeNet::CIM::Response
            # Add specs to test value of response.
        end
    end

    context "create profile_with_payment_profile" do
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

            response, ditto = PaymentGatewayCim.create_profile_with_payment_profile(card, "111111", "22222")
            response.class.should == AuthorizeNet::CIM::Response
            ditto.class.should    == Ditto
            # Add specs to test value of request / response.
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
            # Add specs to test value of request / response.
        end
    end


end


# for customer profile - response

 #<AuthorizeNet::CIM::Response:0x007fb0f43746a8
 # @raw_response=#<Net::HTTPOK 200 OK readbody=true>,
 # @transaction=#<AuthorizeNet::CIM::Transaction:0x007fb0f439e9a8
 # @fields={:cust_id=>649418, :payment_profiles=>[], :validation_mode=>:none},
 # @api_login_id="948bLpzeE8UY",
 # @api_transaction_key="7f7AZ66axeC386q7",
 # @response=#<AuthorizeNet::CIM::Response:0x007fb0f43746a8 ...>,
 # @type="createCustomerProfileRequest",
 # @verify_ssl=false,
 # @reference_id=nil,
 # @gateway="https://apitest.authorize.net/xml/v1/request.api",
 # @delim_char=",",
 # @encap_char=nil,
 # @custom_fields={},
 # @xml="<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <profile>\n    <merchantCustomerId>649418</merchantCustomerId>\n  </profile>\n  <validationMode>none</validationMode>\n</createCustomerProfileRequest>\n">,
 # @root=#<Nokogiri::XML::Element:0x3fd87a1ba250 name="createCustomerProfileResponse" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Element:0x3fd87a19bf1c name="messages" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Element:0x3fd87a1b6df8 name="resultCode" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Text:0x3fd87a19b74c "Ok">]>, #<Nokogiri::XML::Element:0x3fd87a19b594 name="message" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Element:0x3fd87a1b339c name="code" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Text:0x3fd87a19ad60 "I00001">]>, #<Nokogiri::XML::Element:0x3fd87a1afd14 name="text" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Text:0x3fd87a19a6bc "Successful.">]>]>]>, #<Nokogiri::XML::Element:0x3fd87a1ae4a0 name="customerProfileId" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd"> children=[#<Nokogiri::XML::Text:0x3fd87a197d54 "28677882">]>, #<Nokogiri::XML::Element:0x3fd87a1aad50 name="customerPaymentProfileIdList" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd">>, #<Nokogiri::XML::Element:0x3fd87a1aa2c4 name="customerShippingAddressIdList" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd">>, #<Nokogiri::XML::Element:0x3fd87a1a69d0 name="validationDirectResponseList" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd">>]>,
 # @result_code="Ok",
 # @message_code="I00001",
 # @message_text="Successful.",
 # @reference_id=nil,
 # @customer_profile_id="28677882",
 # @customer_payment_profile_id=nil,
 # @customer_payment_profile_id_list=nil,
 # @customer_shipping_address_id_list=nil,
 # @customer_address_id=nil,
 # @validation_direct_response_list=#<Nokogiri::XML::Element:0x3fd87a1a69d0 name="validationDirectResponseList" namespace=#<Nokogiri::XML::Namespace:0x3fd87a1ba160 href="AnetApi/xml/v1/schema/AnetApiSchema.xsd">>,
 # @validation_direct_response=nil,
 # @direct_response=nil,
 # @customer_profile_id_list=nil,
 # @address=nil,
 # @payment_profile=nil,
 # @profile=nil>
