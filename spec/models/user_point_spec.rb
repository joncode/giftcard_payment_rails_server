require 'spec_helper'

describe UserPoint do
	it "builds from factory" do
		social = FactoryGirl.build :user_point
		social.should be_valid
		social.save
	end

	it "should validate one region_id per user_id" do
		old = FactoryGirl.create(:user_point, user_id: 1, region_id: 1)
		new_one =  FactoryGirl.build(:user_point, user_id: 1, region_id: 1)
		new_one.should_not be_valid
	end

	it "should return poitns for redeeming a gift" do


	end
end
