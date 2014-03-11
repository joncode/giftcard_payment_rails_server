require 'spec_helper'

describe "Contacts->Friends" do

    #The 6 states of a user social when the uploads and saves occur

    #contact is a user social wihtout a user_id
    describe :contact_upload do

        it "should create user_social and contact association when none exists" do
            # 1. nothing exists
        end

        it "should create contact association to existing user_social" do
            # 2. contact exists but no contact association
        end

        it "should do nothing when contact and user_social exist w/o user_id" do
             # 3. contact exists and contact association
        end

        it "should create a follower only when user_social exists with user_id" do
            # 4. user social exists and no contact or friend association
        end

        it "should promote the contact association to a follower when cotnact exists and user social has user_id" do
            # 5. user social exists and contact association
            # this should be a test on the user_social model to promote its connections when gets a user
        end

        it "should do nothing when user social has user_id and follwer relation exists" do
             # 6. user social exists and friend association
        end

    end

    describe :user_social_promote do




    end

end