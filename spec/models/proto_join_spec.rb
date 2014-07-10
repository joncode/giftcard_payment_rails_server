require 'spec_helper'

describe ProtoJoin do

	it "should take a gift ID" do
		@proto    = FactoryGirl.create(:proto)
        @proto.socials << FactoryGirl.create(:social)
        pj = @proto.proto_joins.first
        pj.gift_id = 4
        pj.save
        @proto.reload
        @proto.proto_joins.first.gift_id.should == 4
	end

	it "should have unique gift ID" do
		@proto    = FactoryGirl.create(:proto)
		2.times do
        	@proto.socials << FactoryGirl.create(:social)
        end
        pjs = @proto.proto_joins
		pjs[0].gift_id = 6
		pjs[0].save
		pjs[1].gift_id = 6
		pjs[1].should_not be_valid
	end
end
