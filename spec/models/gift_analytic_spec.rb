require 'spec_helper'

describe GiftAnalytic do

	describe "return_date" do

		it "should return the date behind on 14-hour UTC conversion" do
			c = Time.now.utc
			compare_date = c.to_date
			d = c.beginning_of_day
			gift = FactoryGirl.create(:gift, created_at: d)
			puts gift.inspect
			r_date = GiftAnalytic.return_date(gift.created_at)
			r_date.should == compare_date - 1.day
		end

		it "should return the date ahead on 14-hour UTC conversion" do
			c = Time.now.utc
			compare_date = c.to_date
			d = c.beginning_of_hour.change(hour: 14)
			gift = FactoryGirl.create(:gift, created_at: d)
			puts gift.inspect
			r_date = GiftAnalytic.return_date(gift.created_at)
			r_date.should == compare_date
		end

		it "should handle nil" do
			r_date = GiftAnalytic.return_date(nil)
			r_date.should be_nil
		end

	end

	describe "calculate" do

		it "should add values to ga for created at date" do

		end


	end

end