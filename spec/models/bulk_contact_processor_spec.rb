require 'spec_helper'

describe BulkContactProcessor do

    it "should handle all situations at once" do
        3.should == 4
    end

    it "should handle duplicate contacts in all situations not creating any doubles" do
        3.should == 4
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
            user.friends.first.should == ac
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
            user.friends.first.should == ac
        end

        it "should do nothing when app_contact and friendship exists" do
            user        = FactoryGirl.create(:user)
            bc_ary      = [{ "name" => "Random Contact", "network" => 'phone', "network_id" => "(727)466.0987"}]
            bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: user.id)

            app_contact = AppContact.create( name: "Random Contact", network_id: "7274660987", network: 'phone' , user_id: 200)
            user.friends.first.should == ac
            user.friends.count.should == 1
            BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
            ac = AppContact.first
            ac.name.should == "Random Contact"
            ac.network_id.should == "7274660987"
            ac.network.should == 'phone'
            user.friends.first.should == ac
            user.friends.count.should == 1
        end
    end

    it "should return user is invalid if user cannot be found" do
        bc_ary      = [{ "name" => "jon Test", "network" => 'email', "network_id" => 'test@gmail.com'}]
        bulk_contact = FactoryGirl.create(:bulk_contact, data: bc_ary.to_json, user_id: 100000)
        resp = BulkContactProcessor.process(contacts: bulk_contact.normalized_data, user_id: bulk_contact.user_id)
        resp.should == { "user" => "is invalid"}
    end

end