require 'spec_helper'
require 'card_tokenizer'

describe :tokenize do
	it "should create profile and payment profile" do
		user = FactoryGirl.create :user
		card = FactoryGirl.create :card, user_id: user.id
		card.cim_token.should == nil
		user.cim_token.should == nil
		stub_request(
			:post, "https://apitest.authorize.net/xml/v1/request.api"
		).to_return(
			:success? => true
		)
		AuthorizeNet::CIM::Response.any_instance.stub(:success?).and_return(true)
		AuthorizeNet::CIM::Response.any_instance.stub(:profile_id).and_return("11111")
		AuthorizeNet::CIM::Response.any_instance.stub(:payment_profile_ids).and_return(["22222"])
		CardTokenizer.tokenize(card.id)
		card.reload
		user.reload
		user.cim_token.should == "11111"
		card.cim_token.should == "22222"
	end

	it "should add payment to profile if one exists" do
		user = FactoryGirl.create :user, cim_token: "11111"
		card = FactoryGirl.create :card, user_id: user.id
		card.cim_token.should == nil
		user.cim_token.should == "11111"
		stub_request(
			:post, "https://apitest.authorize.net/xml/v1/request.api"
		).to_return(
			:success? => true
		)
		AuthorizeNet::CIM::Response.any_instance.stub(:success?).and_return(true)
		AuthorizeNet::CIM::Response.any_instance.stub(:payment_profile_id).and_return("22222")
		CardTokenizer.tokenize(card.id)
		card.reload
		user.reload
		user.cim_token.should == "11111"
		card.cim_token.should == "22222"
	end
end
