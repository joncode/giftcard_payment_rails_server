require 'spec_helper'

describe Connection do

    before(:each) do
        @ted   = FactoryGirl.create(:user, first_name: "Ted")
        @random_social = FactoryGirl.create(:user_social, user_id: nil)

    end

    it "requires friend_id" do
        connect =  Connection.create(friend_id: nil, contact_id: @random_social.id)
        connect.should_not be_valid
        connect.should have_at_least(1).error_on(:friend_id)
    end

    it "requires contact_id" do
        connect =  Connection.create(friend_id: 10, contact_id: nil)
        connect.should_not be_valid
        connect.should have_at_least(1).error_on(:contact_id)
    end

    it "should associate user with user_social" do
        Connection.create(friend_id: @ted.id, contact_id: @random_social.id)
        @ted.friends.pop.should           == @random_social
        @random_social.friends.pop.should == @ted
    end

    it "should associate the user via build" do
        @ted.connections.create(contact_id: @random_social.id)
        @ted.friends.pop.should           == @random_social
        @random_social.friends.pop.should == @ted
    end

end
# == Schema Information
#
# Table name: connections
#
#  id         :integer         not null, primary key
#  friend_id  :integer
#  contact_id :integer
#  created_at :datetime
#  updated_at :datetime
#

