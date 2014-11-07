require 'spec_helper'

describe FriendMaker do

    context :user_create do

        before(:each) do
            User.any_instance.stub(:init_confirm_email).and_return(true)
            @current = FactoryGirl.create(:user, first_name: "current", last_name: "user", email: "email@friend.com", phone: "6467579999", facebook_id: "123456789", twitter: "9876544321")
            @email_friend    = FactoryGirl.create(:user, first_name: "email", last_name: "friend")
            @multi_friend    = FactoryGirl.create(:user, first_name: "multi", last_name: "friend")
            @phone_friend    = FactoryGirl.create(:user, first_name: "phone", last_name: "friend")
            @twitter_friend  = FactoryGirl.create(:user, first_name: "twitter", last_name: "friend")
            @facebook_friend = FactoryGirl.create(:user, first_name: "facebook", last_name: "friend")
        end

        it "should require a user_id that has a user" do
            resp = FriendMaker.user_create(@current.id + 1000000)
            resp.should == { "user" => "is invalid"}
        end

        it "should make a relationship with app_contact users when none exists" do
            ac = AppContact.create(network: "email", network_id: @current.email )
            Friendship.create(user_id: @email_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "phone", network_id: @current.phone )
            Friendship.create(user_id: @phone_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "facebook", network_id: @current.facebook_id )
            Friendship.create(user_id: @facebook_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "twitter", network_id: @current.twitter)
            Friendship.create(user_id: @twitter_friend.id, app_contact_id: ac.id)
            FriendMaker.user_create(@current.id)
            @email_friend.app_contacts.first.network_id.should == @current.email

            @current.followed_users.first.should == @email_friend
            @email_friend.followers.first.should == @current
            @phone_friend.followers.first.should == @current
            @twitter_friend.followers.first.should  == @current
            @facebook_friend.followers.first.should == @current
        end

        it "should only make one relationship when multiple app_contacts per user exists" do
            ac = AppContact.create(network: "email", network_id: @current.email )
            Friendship.create(user_id: @multi_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "phone", network_id: @current.phone )
            Friendship.create(user_id: @multi_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "facebook", network_id: @current.facebook_id )
            Friendship.create(user_id: @multi_friend.id, app_contact_id: ac.id)
            ac = AppContact.create(network: "twitter", network_id: @current.twitter)
            Friendship.create(user_id: @multi_friend.id, app_contact_id: ac.id)
            FriendMaker.user_create(@current.id)
            @multi_friend.app_contacts.where(network_id: @current.email).count.should == 1

            @current.followed_users.first.should == @multi_friend
            @current.followed_users.count.should == 1
            @multi_friend.followers.first.should == @current
            @multi_friend.followers.count.should  == 1
        end

        it "should not make a relationship when one already exists" do
            ac = AppContact.create(network: "email", network_id: @current.email )
            Friendship.create(user_id: @email_friend.id, app_contact_id: ac.id)
            FriendMaker.user_create(@current.id)
            @email_friend.app_contacts.first.network_id.should == @current.email

            @current.followed_users.first.should == @email_friend
            @email_friend.followers.first.should == @current
            ac = AppContact.create(network: "email", network_id: @current.phone)
            Friendship.create(user_id: @email_friend.id, app_contact_id: ac.id)
            FriendMaker.user_create(@current.id)
            @current.followed_users.count.should == 1
            @email_friend.followers.count.should == 1
        end
    end

    # context :contact_create do

    #     before(:each) do
    #         @current = FactoryGirl.create(:user, first_name: "current", last_name: "user")
    #         @email_friend    = FactoryGirl.create(:user, first_name: "email", last_name: "friend", email: "email@friend.com")
    #         @phone_friend    = FactoryGirl.create(:user, first_name: "phone", last_name: "friend", phone: "6467579999")
    #         @multi_friend    = FactoryGirl.create(:user, first_name: "multi", last_name: "friend", email: "email2@friend.com", phone: "4467579999", facebook_id: "223456789", twitter: "8876544321")
    #         @twitter_friend  = FactoryGirl.create(:user, first_name: "twitter", last_name: "friend", twitter: "9876544321",)
    #         @facebook_friend = FactoryGirl.create(:user, first_name: "facebook", last_name: "friend", facebook_id: "123456789")
    #     end

    #     it "should require a user_id that has a user" do
    #         resp = FriendMaker.contact_create(@current.id + 1000000)
    #         resp.should == { "user" => "is invalid"}
    #     end

    #     it "should make relationships when user_socials exists that match contacts" do
    #         AppContact.create(network: "email", network_id: "email@friend.com", user_id: @current.id )
    #         AppContact.create(network: "phone", network_id: "6467579999", user_id: @current.id )
    #         AppContact.create(network: "facebook", network_id: "123456789", user_id: @current.id )
    #         AppContact.create(network: "twitter", network_id: "9876544321", user_id: @current.id )
    #         FriendMaker.contact_create(@current.id)
    #         @email_friend.followed_users.first.should == @current
    #         @twitter_friend.followed_users.first.should == @current
    #         @facebook_friend.followed_users.first.should == @current
    #         @phone_friend.followed_users.first.should == @current
    #     end

    #     it "should make only one relationship when multiple contacts match multiple user socials" do
    #         AppContact.create(network: "email", network_id: "email2@friend.com", user_id: @current.id )
    #         AppContact.create(network: "phone", network_id: "4467579999", user_id: @current.id )
    #         AppContact.create(network: "facebook", network_id: "223456789", user_id: @current.id )
    #         AppContact.create(network: "twitter", network_id: "8876544321", user_id: @current.id )
    #         FriendMaker.contact_create(@current.id)
    #         @multi_friend.followed_users.count.should == 1
    #         @multi_friend.followed_users.first.should == @current
    #     end

    #     it "should not make relationship when one already exists" do
    #         AppContact.create(network: "email", network_id: "email2@friend.com", user_id: @current.id )
    #         AppContact.create(network: "phone", network_id: "4467579999", user_id: @current.id )
    #         AppContact.create(network: "facebook", network_id: "223456789", user_id: @current.id )
    #         AppContact.create(network: "twitter", network_id: "8876544321", user_id: @current.id )
    #         FriendMaker.contact_create(@current.id)
    #         @multi_friend.followed_users.count.should == 1
    #         @multi_friend.followed_users.first.should == @current
    #         FriendMaker.contact_create(@current.id)
    #         @multi_friend.followed_users.count.should == 1
    #         @multi_friend.followed_users.first.should == @current
    #     end

    # end

end