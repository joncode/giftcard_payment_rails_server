require 'spec_helper'

describe Redemption do

	it "should belong to a gift" do
		g = FactoryGirl.create(:gift)
		r = FactoryGirl.create(:redemption, gift_id: g.id)
		r.gift.should == g
	end

	it "should know it is a positronics redemptions" do
		r = FactoryGirl.create(:redemption)
		r.positronics?.should be_true
		r.type_of.should == "positronics"
	end

	it "builds from factory" do
	  	redemption = FactoryGirl.create :redemption
	  	redemption.should be_valid
	end
end
