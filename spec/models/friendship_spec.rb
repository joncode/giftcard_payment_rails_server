require 'spec_helper'

describe Friendship do

    it "require user_id" do
        friends = Friendship.create(app_contact_id: 1)
        friends.should_not be_valid
        friends.should have_at_least(1).error_on(:user_id)
    end

    it "require user_id" do
        friends = Friendship.create(user_id: 1)
        friends.should_not be_valid
        friends.should have_at_least(1).error_on(:user_id)
    end

    it "should return existing friends when Friendship already exists" do
        old_friends = Friendship.create(app_contact_id: 1, user_id: 23)
        friends = Friendship.create(app_contact_id: 1, user_id: 23)
        friends.should_not be_valid
        friends.should have_at_least(1).error_on(:user_id)
    end

    it "should get app_contacts via Friendship for user" do
        ac1 = FactoryGirl.build(:app_contact)
        ac2 = AppContact.build(network: 'facebook', network_id: "18723561872")
        ac3 = AppContact.build(network: 'twitter', network_id: "87897944")
    end
end
