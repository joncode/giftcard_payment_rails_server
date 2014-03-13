require 'spec_helper'

describe Relationship do

    before(:each) do
        @ted   = FactoryGirl.create(:user, first_name: "Ted")
        @bryan = FactoryGirl.create(:user, first_name: "Bryan")
    end

    it "requires follower" do
        relate =  Relationship.create(follower_id: nil, followed_id: @bryan.id)
        relate.should_not be_valid
        relate.should have_at_least(1).error_on(:follower_id)
    end

    it "requires followed_user" do
        relate =  Relationship.create(follower_id: 10, followed_id: nil)
        relate.should_not be_valid
        relate.should have_at_least(1).error_on(:followed_id)
    end

    it "should associate user with user" do
        Relationship.create(follower_id: @ted.id, followed_id: @bryan.id)
        @ted.followed_users.pop.should  == @bryan
        @bryan.followers.pop.should     == @ted
    end

    it "should associate the user via build" do
        @ted.relationships.create(followed_id: @bryan.id)
        @ted.followed_users.pop.should  == @bryan
        @bryan.followers.pop.should     == @ted
    end

    it "should associate the user via build" do
        @ted.reverse_relationships.create(follower_id: @bryan.id)
        @ted.followers.pop.should        == @bryan
        @bryan.followed_users.pop.should == @ted
    end

    it "should associate user with user" do
        Relationship.create(followed_id: @ted.id, follower_id: @bryan.id)
        @ted.followers.pop.should        == @bryan
        @bryan.followed_users.pop.should == @ted
    end

    it "should autosave follower with user :save" do
        user       = FactoryGirl.create(:user)
        other_user = FactoryGirl.create(:user, first_name: "follower")
        user.followers.count.should == 0
        user.followers << other_user
        user.save
        user.followers.count.should == 1
        user.followers.first.should == other_user
        other_user.followed_users.first.should == user
        other_user.followers.count.should == 0
    end

    it "should autosave follower with user :save" do
        user       = FactoryGirl.create(:user)
        other_user = FactoryGirl.create(:user, first_name: "follower")
        user.followed_users.count.should == 0
        user.followed_users << other_user
        user.save
        user.followed_users.count.should == 1
        user.followed_users.first.should == other_user
        other_user.followers.first.should == user
        user.followers.count.should == 0
    end

    it "should return existing relationship when Relationship already exists" do
        r = Relationship.create(follower_id: @ted.id, followed_id: @bryan.id)
        r.class.should == Relationship
        @ted.followed_users.pop.should  == @bryan
        @bryan.followers.pop.should     == @ted
        Relationship.create(follower_id: @ted.id, followed_id: @bryan.id)
        Relationship.all.count.should == 1
    end
end# == Schema Information
#
# Table name: relationships
#
#  id          :integer         not null, primary key
#  follower_id :integer
#  followed_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

