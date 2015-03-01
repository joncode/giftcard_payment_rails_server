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
# == Schema Information
#
# Table name: user_points
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  region_id  :integer         default(0)
#  points     :integer         default(0)
#  created_at :datetime
#  updated_at :datetime
#

