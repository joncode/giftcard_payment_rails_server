require 'spec_helper'

describe Friendship do

    it "require app_contact_id" do
        friends = Friendship.create(app_contact_id: 1)
        friends.should_not be_valid
        friends.should have_at_least(1).error_on(:user_id)
    end

    it "require user_id" do
        friends = Friendship.create(user_id: 1)
        friends.should_not be_valid
        friends.should have_at_least(1).error_on(:app_contact_id)
    end

    it "should save app_contacts via user append" do
        ac1 = FactoryGirl.build(:app_contact)
        ac2 = AppContact.new(network: 'facebook', network_id: "18723561872")
        ac3 = AppContact.new(network: 'twitter', network_id: "87897944")
        user = FactoryGirl.create(:user)
        user.app_contacts << [ac1, ac2, ac3]
        acs = AppContact.all
        ac = acs.where(network: 'facebook', network_id: "18723561872")
        ac.count.should == 1
        ac.first.users.first.should == user
        ac = acs.where(network: 'twitter', network_id: "87897944")
        ac.count.should == 1
        ac.first.users.first.should == user
        ac = acs.where(network: ac1.network, network_id: ac1.network_id)
        ac.count.should == 1
        ac.first.users.first.should == user
    end


    it "should return true when Friendship already exists" do
        r = Friendship.create(app_contact_id: 1, user_id: 23)
        r.class.should == Friendship

        r2 = Friendship.create(app_contact_id: 1, user_id: 23)
        Friendship.all.count.should == 1
        r2.should be_true
    end
end
