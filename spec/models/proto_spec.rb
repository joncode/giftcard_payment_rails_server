require 'spec_helper'

describe Proto do

	it "builds from factory" do
		proto = FactoryGirl.build :proto
		proto.should be_valid
		proto.save
	end

	context "Associations" do

		it "should associate with users" do
			user               = FactoryGirl.create(:user)
			proto              = FactoryGirl.create(:proto)
			proto.users << user
			reload_proto       = Proto.last
			proto.users.should == [user]
			proto.receivables.count.should  == 1
		end

		it "should associate with socials" do
			social                        = FactoryGirl.create(:social)
			proto                         = FactoryGirl.create(:proto)
			proto.socials << social
			reload_proto                  = Proto.last
			proto.socials.should          == [social]
			proto.receivables.count.should == 1
		end

		it "should associate with both users and socials" do
			user                           = FactoryGirl.create(:user)
			social                         = FactoryGirl.create(:social)
			proto                          = FactoryGirl.create(:proto)
			proto.socials << social
			proto.users    << user
			reload_proto                   = Proto.last
			proto.socials.should           == [social]
			proto.users.should             == [user]
			proto.proto_joins.count.should == 2
			proto.receivables.count.should  == 2
		end

		it "should associate with both users and socials" do
			user                           = FactoryGirl.create(:user)
			social                         = FactoryGirl.create(:social)
			proto                          = FactoryGirl.create(:proto)
			proto.socials << social
			proto.users    << user
			reload_proto                   = Proto.last
			proto.socials.should           == [social]
			proto.users.should             == [user]
			proto.proto_joins.count.should == 2
			proto.receivables.count.should  == 2
		end

		it "should associate with gifts as payable and autosave" do
			social                         = FactoryGirl.create(:social)
			proto                          = FactoryGirl.build(:proto)
			proto.socials << social
			proto.id.should be_nil
			gift         = FactoryGirl.build(:gift)
			gift.payable = proto
			gift.save
			gift.reload
			gift.payable_id.should   == proto.id
			gift.payable_type.should == proto.class.to_s
			gift.payable.should      == proto
		end
	end
end
