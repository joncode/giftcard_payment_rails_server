require 'spec_helper'
require 'card_tokenizer'

describe "Should tokenize card" do
	it "should tokenize card" do
		user = FactoryGirl.create :user
		card = FactoryGirl.create :card, user_id: user.id
		card.payment_profile_id.should == nil
		stub_request(:post, "https://apitest.authorize.net/xml/v1/request.api").to_return(:status => 200, :body => "", :headers => {})
		CardTokenizer.tokenize(card.id)
		card.reload
		card.payment_profile_id.should_not == nil
	end
end