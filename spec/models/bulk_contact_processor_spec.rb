require 'spec_helper'

describe BulkContactProcessor do

    it "should handle all situations at once and not make duplicates" do
        user         = FactoryGirl.create(:user)

        # in his contact book is
            # user_socials connected to his relationship
        follower  = FactoryGirl.create(:user, first_name: "follower", last_name: "user")
        Relationship.create(follower_id: follower.id, followed_id: user.id)

            # user_social for users wihout relationships
        non_follower = FactoryGirl.create(:user, first_name: "non_follower", last_name: "user")

            # app_contacts that he already has Friendships with
        friended  = AppContact.create(network: 'email', network_id: 'friended@gmail.com')
        friended2 = AppContact.create(network: 'phone', network_id: '6467578990')
        Friendship.create(user_id: user.id, app_contact_id: friended.id)
        Friendship.create(user_id: user.id, app_contact_id: friended2.id)

            # app_contacts in database but no friendship yet
        not_friends  = AppContact.create(network: 'twitter', network_id: '12315247612')
        not_friends2 = AppContact.create(network: 'facebook', network_id: '7283548152')

            # contacts that are not in user_social or app_contacts
        # put nothing in db

            # user uploads his contact book to BulkContacts
        bc_ary = [{network: "facebook", network_id: "7283548152", name: "Jameson Kieler", birthday: "10/12/77"},
            {network: "twitter", network_id: "12315247612", name: "Boy George",  handle: "@razorface"},
            { network: "email", network_id: "friended@gmail.com", name: "Chan Khan", birthday: "1/4/81"},
            { network: "phone", network_id: "6467578990", name: "Jameson Kieler"},
            { network: "facebook", network_id: "98a3fd332", name: "Jameson Kieler", birthday: "10/12/77"},
            {network: "twitter", network_id: "283s3f6fd3", name: "Evil Canivel",  handle: "@razorface"},
            { network: "email", network_id: "thisguy3@gmail.com", name: "Kill Switch", birthday: "1/4/81"},
            { network: "email", network_id: "unknown@gmail.com", name: "Unknown Person"},
            { network: "facebook", network_id: "98a2fd332", name: "Jameson Kieler", birthday: "10/12/77"},
            {network: "twitter", network_id: "283s2f6fd3", name: "Evil Canivel",  handle: "@razorface"},
            { network: "email", network_id: "thisguy2@gmail.com", name: "Kill Switch", birthday: "1/4/81"},
            { network: "facebook", network_id: "41268248386", name: "Unknown Contact"},
            { network: "facebook", network_id: "98a1fd332", name: "Myself", birthday: "10/12/77"},
            {network: "twitter", network_id: "283s1f6fd3", name: "Evil Canivel",  handle: "@razorface"},
            { network: "email", network_id: "thisguy1@gmail.com", name: "Myself", birthday: "1/4/81"},
            { network: "phone", network_id: "5784426858", name: "Unknown Contact"}]
        bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: user.id)
        BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)

            # tests
        # user has two followers - follower & non_follower
        user.followers.count.should == 3
        user.followers.each do |follow|
            [user.id, follower.id, non_follower.id].include?(follow.id).should be_true
        end

            # user has 7 friendships to 7 app_contacts, 4 of which existed already
        user.app_contacts.count.should == 7
        current_connects = 0
        user.app_contacts.each do |friend|
            if [friended.id, friended2.id, not_friends.id, not_friends2.id].include?(friend.id)
                current_connects += 1
            end
        end
        current_connects.should == 4
    end

    context "has user social" do

        it "should find user_socials for contacts and do nothing if relationship exists" do
            user        = FactoryGirl.create(:user)
            user_social = FactoryGirl.create(:user_social, user: user)
            other_user  = FactoryGirl.create(:user, first_name: "other", last_name: "user")
            Relationship.create(follower_id: user.id, followed_id: other_user.id)
            other_user.followers.first.should == user
            bc_ary      = [{ "name" => other_user.name, "network" => user_social.type_of, "network_id" => user_social.identifier}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: other_user.id)
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            relate = Relationship.where(follower_id: user.id, followed_id: other_user.id)
            relate.count.should == 1
            other_user.followers.first.should == user
        end

        it "should create relationships when missing" do
            user        = FactoryGirl.create(:user)
            user_social = FactoryGirl.create(:user_social, user: user)
            other_user  = FactoryGirl.create(:user, first_name: "other", last_name: "user")
            other_user.followers.first.should_not == user
            bc_ary      = [{ "name" => other_user.name, "network" => user_social.type_of, "network_id" => user_social.identifier}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: other_user.id)
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            relate = Relationship.where(follower_id: user.id, followed_id: other_user.id)
            relate.count.should == 1
            other_user.followers.first.should == user
        end

    end

    context "no user_social" do

        it "should create app_contact / friendship when none" do
            user        = FactoryGirl.create(:user)
            bc_ary      = [{ "name" => "Random Contact", "network" => 'phone', "network_id" => "(727)466.0987"}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: user.id)
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            ac = AppContact.first

            ac.name.should                 == "Random Contact"
            ac.network_id.should           == "7274660987"
            ac.network.should              == 'phone'
            user.app_contacts.first.should == ac
        end

        it "should make friendship when missing but has app_contact" do
            user        = FactoryGirl.create(:user)
            bc_ary      = [{ "name" => "Random Contact", "network" => 'phone', "network_id" => "(727)466.0987"}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: user.id)
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            ac = AppContact.first
            ac.name.should            == "Random Contact"
            ac.network_id.should      == "7274660987"
            ac.network.should         == 'phone'
            user.app_contacts.first.should == ac
        end

        it "should do nothing when app_contact and friendship exists" do
            user        = FactoryGirl.create(:user)
            bc_ary      = [{ "name" => "Random Contact", "network" => 'phone', "network_id" => "(727)466.0987"}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: user.id)

            app_contact = AppContact.create( name: "Random Contact", network_id: "7274660987", network: 'phone')
            user.app_contacts << app_contact
            user.app_contacts.first.should == app_contact
            user.app_contacts.count.should == 1
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            ac = AppContact.first
            ac.name.should          == "Random Contact"
            ac.network_id.should    == "7274660987"
            ac.network.should       == 'phone'
            user.app_contacts.first.should == ac
            user.app_contacts.count.should == 1
        end
    end

    it "should return user is invalid if user cannot be found" do
        bc_ary      = [{ "name" => "jon Test", "network" => 'email', "network_id" => 'test@gmail.com'}]
        bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: 100000)
        resp = BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
        resp.should == { "user" => "is invalid"}
    end

end