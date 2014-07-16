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

	it "should have unique gift ID per receivable" do
		@proto    = FactoryGirl.create(:proto)
		social    = FactoryGirl.create(:social)
        @proto.socials << social
        pjs = @proto.proto_joins
		pjs[0].gift_id = 6
		pjs[0].save

		@proto.socials << social
		pjs = @proto.proto_joins
		pjs.count.should == 2
		pjs[1].gift_id = 6
		pjs[1].should_not be_valid
	end

	it "should allow only 1 proto join ber proto/receivable" do
		proto     = FactoryGirl.create(:proto)
		social    = FactoryGirl.create(:social)
		pj    = ProtoJoin.create(proto_id: proto.id, receivable_id: social.id, receivable_type: 'Social')
		pj2   = ProtoJoin.create(proto_id: proto.id, receivable_id: social.id, receivable_type: 'Social')
		joins = ProtoJoin.all
		joins.count.should == 1
		ProtoJoin.delete_all
		pj    = ProtoJoin.create(proto_id: proto.id, receivable_id: social.id, receivable_type: 'Social')
		pj2   = ProtoJoin.create(proto_id: proto.id, receivable_id: social.id, receivable_type: 'User')
		joins = ProtoJoin.all
		joins.count.should == 2

	end
end
