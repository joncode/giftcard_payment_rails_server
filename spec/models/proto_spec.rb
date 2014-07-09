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
			proto.receivable.count.should  == 1
		end

		it "should associate with contacts" do
			contact               = FactoryGirl.create(:contact)
			proto                 = FactoryGirl.create(:proto)
			proto.contacts << contact
			reload_proto          = Proto.last
			proto.contacts.should == [contact]
			proto.receivable.count.should  == 1
		end

		it "should associate with both users and contacts" do
			user                  = FactoryGirl.create(:user)
			contact               = FactoryGirl.create(:contact)
			proto                 = FactoryGirl.create(:proto)
			proto.contacts << contact
			proto.users    << user
			reload_proto          = Proto.last
			proto.contacts.should == [contact]
			proto.users.should    == [user]
			proto.proto_joins.count.should == 2
			proto.receivable.count.should  == 2
		end

		it "should associate with both users and contacts" do
			user                  = FactoryGirl.create(:user)
			contact               = FactoryGirl.create(:contact)
			proto                 = FactoryGirl.create(:proto)
			proto.contacts << contact
			proto.users    << user
			reload_proto          = Proto.last
			proto.contacts.should == [contact]
			proto.users.should    == [user]
			proto.proto_joins.count.should == 2
			proto.receivable.count.should  == 2
		end
	end
end
