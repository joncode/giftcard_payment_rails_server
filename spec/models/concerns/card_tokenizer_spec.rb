require 'spec_helper'

describe :tokenize do

	it "should create profile and payment profile" do
		user = FactoryGirl.create :user
		customer_id = user.obscured_id
		stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").
         with(:body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n<createCustomerProfileRequest xmlns=\"AnetApi/xml/v1/schema/AnetApiSchema.xsd\">\n  <merchantAuthentication>\n    <name>948bLpzeE8UY</name>\n    <transactionKey>7f7AZ66axeC386q7</transactionKey>\n  </merchantAuthentication>\n  <profile>\n    <merchantCustomerId>#{customer_id}</merchantCustomerId>\n    <paymentProfiles>\n      <payment>\n        <creditCard>\n          <cardNumber>4417121029961508</cardNumber>\n          <expirationDate>2017-02</expirationDate>\n        </creditCard>\n      </payment>\n    </paymentProfiles>\n  </profile>\n  <validationMode>none</validationMode>\n</createCustomerProfileRequest>\n",
              :headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body => "", :headers => {})
		card = FactoryGirl.create :card, user_id: user.id
		card.cim_token.should == nil
		user.cim_profile.should == nil
		response = AuthorizeNet::CIM::Response.new("111", "111")
		ditto    = Ditto.new
		PaymentGatewayCim.should_receive(:create_profile).and_return([response, ditto])
		AuthorizeNet::CIM::Response.any_instance.stub(:success?).and_return(true)
		AuthorizeNet::CIM::Response.any_instance.stub(:profile_id).and_return("11111")
		AuthorizeNet::CIM::Response.any_instance.stub(:payment_profile_ids).and_return(["22222"])
		card.tokenize
		card.reload
		user.reload
		user.cim_profile.should == "11111"
		card.cim_token.should == "22222"
	end

	it "should add payment to profile if one exists" do
		user = FactoryGirl.create :user, cim_profile: "11111"
		card = FactoryGirl.create :card, user_id: user.id
		card.cim_token.should == nil
		user.cim_profile.should == "11111"
		PaymentGatewayCim.should_receive(:add_payment_profile).and_return(AuthorizeNet::CIM::Response.new("111", "111"))
		AuthorizeNet::CIM::Response.any_instance.stub(:success?).and_return(true)
		AuthorizeNet::CIM::Response.any_instance.stub(:payment_profile_id).and_return("22222")
		card.tokenize
		card.reload
		user.reload
		user.cim_profile.should == "11111"
		card.cim_token.should == "22222"
	end

end

 # POST https://apitest.authorize.net/xml/v1/request.api with body '<?xml version="1.0" encoding="utf-8"?>
 #       <createCustomerPaymentProfileRequest xmlns="AnetApi/xml/v1/schema/AnetApiSchema.xsd">
 #         <merchantAuthentication>
 #           <name>948bLpzeE8UY</name>
 #           <transactionKey>7f7AZ66axeC386q7</transactionKey>
 #         </merchantAuthentication>
 #         <customerProfileId>11111</customerProfileId>
 #         <paymentProfile>
 #           <payment>
 #             <creditCard>
 #               <cardNumber>4417121029961508</cardNumber>
 #               <expirationDate>2017-02</expirationDate>
 #             </creditCard>
 #           </payment>
 #         </paymentProfile>
 #         <validationMode>none</validationMode>
 #       </createCustomerPaymentProfileRequest>
 #       ' with headers {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'Content-Type'=>'text/xml', 'User-Agent'=>'Ruby'}

