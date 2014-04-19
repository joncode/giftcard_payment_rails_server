require 'spec_helper'

describe Redeem do

	it "validates uniqueness of pos_mechant_id & redeem_code" do
		redeem = FactoryGirl.create(:redeem, redeem_code: "unique", pos_merchant_id: 12312)
		redeem_valid = FactoryGirl.build(:redeem, redeem_code: "unique", pos_merchant_id: 845794)

		redeem_invalid = FactoryGirl.build(:redeem, redeem_code: "unique", pos_merchant_id: 12312)
		redeem_valid.redeem_code = redeem.redeem_code
		redeem_valid.should be_valid
		redeem_valid.should_not have_at_least(1).error_on(:redeem_code)
		redeem_invalid.redeem_code = redeem.redeem_code
		redeem_invalid.should_not be_valid
		redeem_invalid.should have_at_least(1).error_on(:redeem_code)
	end


	it "should not validate uniqueness of redeem_code if pos_mechant_id is nil" do
		redeem = FactoryGirl.create(:redeem, redeem_code: "unique", pos_merchant_id: nil)
		redeem_valid = FactoryGirl.build(:redeem, redeem_code: "unique", pos_merchant_id: nil)

		redeem_invalid = FactoryGirl.build(:redeem, redeem_code: "unique", pos_merchant_id: nil)
		redeem_valid.redeem_code = redeem.redeem_code
		redeem_valid.should be_valid
		redeem_valid.should_not have_at_least(1).error_on(:redeem_code)
		redeem_invalid.redeem_code = redeem.redeem_code
		redeem_invalid.should be_valid
		redeem_invalid.should_not have_at_least(1).error_on(:redeem_code)
	end

	it "should auto store the pos_merchant_id when provider has one" do
		provider = FactoryGirl.create(:provider, pos_merchant_id: 56456)
		gift     = FactoryGirl.create(:gift, provider_id: provider.id)
		redeem   = Redeem.find_or_create_with_gift(gift)
		redeem.pos_merchant_id.should == provider.pos_merchant_id
	end

	it "builds from factory" do
	  	redeem = FactoryGirl.create :redeem
	  	redeem.should be_valid
	end

	it "requires gift_id" do
		redeem = FactoryGirl.build(:redeem, :gift_id => nil)
		redeem.should_not be_valid
		redeem.should have_at_least(1).error_on(:gift_id)
	end

	it "validates uniqueness of gift_id" do
		previous = FactoryGirl.create(:order)
		order = FactoryGirl.build(:order, :gift_id => previous.gift_id)
		order.should_not be_valid
		order.should have_at_least(1).error_on(:gift_id)
			#order.errors.full_messages.should include("Validation msg about gift id")
	end

	it "should not change already redeemed gifts" do
		user = FactoryGirl.create(:user)
		gift = FactoryGirl.create(:gift, receiver_id: user.id, receiver_name: user.name)
		redeem = Redeem.find_or_create_with_gift(gift)
		redeem2 = Redeem.find_or_create_with_gift(gift)
		redeem.should == redeem2
		order = Order.init_with_gift(gift)
		order.save
		gift.reload
		gift.status.should == 'redeemed'
		redeem3 = Redeem.find_or_create_with_gift(gift)
		redeem3.should == redeem
	end
end



  # validates :gift_id   , presence: true, uniqueness: true# == Schema Information
#
# Table name: redeems
#
#  id          :integer         not null, primary key
#  gift_id     :integer
#  redeem_code :string(255)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

