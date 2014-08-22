require 'spec_helper'

describe :tokenize do
	it "should create profile and payment profile" do
		user = FactoryGirl.create :user
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
