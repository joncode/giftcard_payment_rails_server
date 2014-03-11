require 'spec_helper'

describe ContactUpload do

    before(:each)do
        @current_user = FactoryGirl.create(:user)
        @ary = [{ "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"], "phone" => [ "3102974545", "6467586473"], "twitter" => [ "2i134o1234123"], "facebook" => [ "23g2381d103dy1"] }}, { "22" => { "first_name" => "Jenifer" ,"last_name" => "Bowie", "email" => [ "jenny@facebook.com"], "phone" => ["7824657878"]}}]
    end

    it "should accept ary of contacts separated by ID and make array of contact hashes" do
        cu = ContactUpload.new(@ary, @current_user)
        cu.ary.count.should == 8
        cu.ary.first[:type_of].should    == "email"
        cu.ary.first[:identifier].should == "email1@gmail.com"
        cu.ary.first[:name].should       == "tommy hilfigure"
    end

    it "should find or create contacts that are already in user_social database" do
        user = FactoryGirl.create(:user)
        us = FactoryGirl.create(:user_social, type_of: "email", identifier: "email1@gmail.com", user_id: user.id)
        ary = [{ "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"] }}]
        cu = ContactUpload.new(ary, @current_user)
        uss = cu.socials
        uss.first.should == us
        uss.last.identifier.should == "email2@yahoo.com"
        uss.last.id.should_not be_nil
        uss.last.type_of.should == "email"
        uss.count.should == 2
    end

    it "should initialize connections objects" do
        user = FactoryGirl.create(:user)
        us = FactoryGirl.create(:user_social, type_of: "email", identifier: "email1@gmail.com", user_id: user.id)
        ary = [{ "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"] }}]
        cu = ContactUpload.new(ary, @current_user)
        uss = cu.socials
        uss.each { |us| us.save }
        connections = cu.connections
        connections.count.should == 1
        connection = connections.first
        connection.friend_id.should  == @current_user.id
        us2 = UserSocial.unscoped.where(identifier: "email2@yahoo.com").first
        connection.contact_id.should == us2.id
        connsaved = Connection.all
        connsaved.count.should == 1
        us2.friends.pop.should == @current_user
    end

    it "should connect contacts without user_ids in relationships" do
        user = FactoryGirl.create(:user)
        us = FactoryGirl.create(:user_social, type_of: "email", identifier: "email1@gmail.com", user_id: user.id)
        ary = [{ "672342" => { "first_name" => "tommy" ,"last_name" => "hilfigure", "email" => [ "email1@gmail.com", "email2@yahoo.com"] }}]
        cu = ContactUpload.new(ary, @current_user)
        relationships = cu.relationships
        relationships.count.should == 1
        relationship = relationships.first
        relationship.follower_id.should  == @current_user.id
        relationship.followed_id.should  == us.user_id
        realtionsaved = Relationship.all
        realtionsaved.count.should == 1
        user.followers.pop.should == @current_user
    end
end



    # when the contacts are uploaded ->
    #     1. compare try to save the contact with the identifier validator
    #     2a. has a user_id               - create a relationship record between contact owner and user_social user
    #     2b. has a record but no user_id - create a friend record between user social and app user id
    #     2c. no user social record       - create a user social record and then a friend record

    # :contact_id :
    # { "first_name" : <first_name> ,
    #     "last_name" : <last_name>,
    #     "emails"    : [ <email1>, <email2>],
    #     "phones"   : [ <phone1>, <phone2>],
    #     "twitters" : [ <twitter1-handle>]
    # }