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

	it "should autosave with gift" do
		gift = FactoryGirl.create(:gift)
		r = FactoryGirl.build(:redemption, gift_id: gift.id)
		gift.detail = "Test Detail"
		ary = gift.redemptions
		gift.redemptions << r
		gift.save
		gift.reload
		gift.redemptions.should == [r]
		gift.detail.should == "Test Detail"
		r.reload.gift_id.should == gift.id
	end

	it "builds from factory" do
	  	redemption = FactoryGirl.create :redemption
	  	redemption.should be_valid
	end
end
# == Schema Information
#
# Table name: redemptions
#
#  id              :integer         not null, primary key
#  gift_id         :integer
#  amount          :integer         default(0)
#  ticket_id       :string(255)
#  req_json        :json
#  resp_json       :json
#  type_of         :integer         default(0)
#  gift_prev_value :integer         default(0)
#  gift_next_value :integer         default(0)
#  created_at      :datetime
#  updated_at      :datetime
#

