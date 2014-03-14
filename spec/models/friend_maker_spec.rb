require 'spec_helper'

describe FriendMaker do

    before(:each) do
        @current = FactoryGirl.create(:user, first_name: "current", last_name: "user", email: "email@friend.com", phone: "6467579999", facebook_id: "123456789", twitter: "9876544321")
        @email_friend    = FactoryGirl.create(:user, first_name: "email", last_name: "friend")
        @multi_friend    = FactoryGirl.create(:user, first_name: "multi", last_name: "friend")
        @phone_friend    = FactoryGirl.create(:user, first_name: "phone", last_name: "friend")
        @twitter_friend  = FactoryGirl.create(:user, first_name: "twitter", last_name: "friend")
        @facebook_friend = FactoryGirl.create(:user, first_name: "facebook", last_name: "friend")
    end

    context :create do

        it "should require a user_id that has a user" do
            resp = FriendMaker.create(@current.id + 1000000)
            resp.should == { "user" => "is invalid"}
        end

        it "should make a relationship with app_contact users when none exists" do
            AppContact.create(network: "email", network_id: @current.email, user_id: @email_friend.id )
            AppContact.create(network: "phone", network_id: @current.phone, user_id: @phone_friend.id )
            AppContact.create(network: "facebook", network_id: @current.facebook_id, user_id: @facebook_friend.id )
            AppContact.create(network: "twitter", network_id: @current.twitter, user_id: @twitter_friend.id )
            FriendMaker.create(@current.id)
            @email_friend.app_contacts.first.network_id.should == @current.email

            @current.followed_users.first.should == @email_friend
            @email_friend.followers.first.should == @current
            @phone_friend.followers.first.should == @current
            @twitter_friend.followers.first.should  == @current
            @facebook_friend.followers.first.should == @current
        end

        it "should only make one relationship when multiple app_contacts per user exists" do
            AppContact.create(network: "email", network_id: @current.email, user_id: @multi_friend.id )
            AppContact.create(network: "phone", network_id: @current.phone, user_id: @multi_friend.id )
            AppContact.create(network: "facebook", network_id: @current.facebook_id, user_id: @multi_friend.id )
            AppContact.create(network: "twitter", network_id: @current.twitter, user_id: @multi_friend.id )
            FriendMaker.create(@current.id)
            @multi_friend.app_contacts.where(network_id: @current.email).count.should == 1

            @current.followed_users.first.should == @multi_friend
            @current.followed_users.count.should == 1
            @multi_friend.followers.first.should == @current
            @multi_friend.followers.count.should  == 1
        end

        it "should not make a relationship when one already exists" do
            AppContact.create(network: "email", network_id: @current.email, user_id: @email_friend.id )
            FriendMaker.create(@current.id)
            @email_friend.app_contacts.first.network_id.should == @current.email

            @current.followed_users.first.should == @email_friend
            @email_friend.followers.first.should == @current
            FriendMaker.create(@current.id)
            @current.followed_users.count.should == 1
            @email_friend.followers.count.should == 1
        end
    end

end