require 'spec_helper'

# this module is EXTENDED onto PaymentGatewayCim

describe PaymentGatewayStorage do

	describe :create_customer_profile do

		it "should create a ditto & response object" do
			user                  = FactoryGirl.create(:user)
			customer_id = user.obscured_id
				stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
	         with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <profile>\n    <merchantCustomerId>#{customer_id}</merchantCustomerId>\n  </profile>\n  <validationMode>none</validationMode>\n</createCustomerProfileRequest>\n",
	              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
	         to_return(:status => 200, :body => "", :headers => {})
			response              = PaymentGatewayCim.create_customer_profile(customer_id)
			response.class.should == AuthorizeNet::CIM::Response
			ditto                 = Ditto.last
            ditto.notable_id.should == user.id
            ditto.notable_type.should == "User"
		end

	end

	describe :create_profile_with_payment_profile do

		it "should create a ditto & response object" do
				stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
	         with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <profile>\n    <merchantCustomerId>235428346</merchantCustomerId>\n    <paymentProfiles>\n      <payment>\n        <creditCard>\n          <cardNumber>4111111111111111</cardNumber>\n          <expirationDate>2017-02</expirationDate>\n        </creditCard>\n      </payment>\n    </paymentProfiles>\n  </profile>\n  <validationMode>none</validationMode>\n</createCustomerProfileRequest>\n",
	              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
	         to_return(:status => 200, :body => "", :headers => {})
			user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:card, :user_id => user.id)

			response              = PaymentGatewayCim.create_profile_with_payment_profile(card, "4111111111111111", "235428346")
			response.first.class.should == AuthorizeNet::CIM::Response
			ditto                 = Ditto.last
            ditto.notable_id.should == card.id
		end

	end

	describe :add_payment_profile do

		it "should create a ditto & response object" do
				stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
	         with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerPaymentProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <customerProfileId>235428346</customerProfileId>\n  <paymentProfile>\n    <payment>\n      <creditCard>\n        <cardNumber>4111111111111111</cardNumber>\n        <expirationDate>2017-02</expirationDate>\n      </creditCard>\n    </payment>\n  </paymentProfile>\n  <validationMode>none</validationMode>\n</createCustomerPaymentProfileRequest>\n",
	              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
	         to_return(:status => 200, :body => "", :headers => {})

			user = FactoryGirl.create(:user)
            card = FactoryGirl.create(:card, :user_id => user.id)
			response              = PaymentGatewayCim.add_payment_profile(card, "4111111111111111", "235428346")
			response.first.class.should == AuthorizeNet::CIM::Response
			ditto                 = Ditto.last
            ditto.notable_id.should == card.id
		end

	end

	describe :delete_payment_profile do

		it "should create a ditto & response object" do
				stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
	         with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<deleteCustomerPaymentProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <customerPaymentProfileId>73548273</customerPaymentProfileId>\n</deleteCustomerPaymentProfileRequest>\n",
	              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
	         to_return(:status => 200, :body => "", :headers => {})
			user                  = FactoryGirl.create(:user)
			card = FactoryGirl.create(:card, :user_id => user.id, cim_token: "73548273")
			response              = PaymentGatewayCim.delete_payment_profile(card.cim_token, user.cim_profile, user.id)
			response.class.should == AuthorizeNet::CIM::Response
			ditto                 = Ditto.last
            ditto.notable_id.should == user.id
		end

	end

end