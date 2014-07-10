require 'spec_helper'

describe PeopleFinder do

    before do
        @user  = FactoryGirl.create(:user, facebook_id: "peoplefinder")
        @user2 = FactoryGirl.create(:user, phone: "5646776465")
        @user3 = FactoryGirl.create(:user, email: "finder@people.com")
        @user4 = FactoryGirl.create(:user, twitter: "456457654")
    end

    it "should receive hash and return associated user" do
        hsh = { facebook_id: "peoplefinder"}
        response = PeopleFinder.find(hsh)
        response.should == @user
        hsh = { phone: "5646776465"}
        response = PeopleFinder.find(hsh)
        response.should == @user2
        hsh = { email: "finder@people.com"}
        response = PeopleFinder.find(hsh)
        response.should == @user3
        hsh = { twitter: "456457654"}
        response = PeopleFinder.find(hsh)
        response.should == @user4
        hsh = { receiver_phone: "5646776465"}
        response = PeopleFinder.find(hsh)
        response.should == @user2
        hsh = { receiver_email: "finder@people.com"}
        response = PeopleFinder.find(hsh)
        response.should == @user3
    end

    it "should return false if no associated user is found" do
        hsh = { facebook_id: "nofindthis"}
        response = PeopleFinder.find(hsh)
        response.should == false
        hsh = { phone: "24354673643"}
        response = PeopleFinder.find(hsh)
        response.should == false
        hsh = { email: "nope@people.com"}
        response = PeopleFinder.find(hsh)
        response.should == false
        hsh = { twitter: "456427654"}
        response = PeopleFinder.find(hsh)
        response.should == false
        hsh = { receiver_phone: "5646376465"}
        response = PeopleFinder.find(hsh)
        response.should == false
        hsh = { receiver_email: "nope@people.com"}
        response = PeopleFinder.find(hsh)
        response.should == false
    end

    it "should look thru multiple ID's and return first user found with prioritized keys" do
        hsh = {facebook_id: "peoplefinder", receiver_phone: "5646776465", email: "finder@people.com", twitter: "456457654"}
        response = PeopleFinder.find(hsh)
        response.should == @user
        hsh = {email: "finder@people.com", twitter: "456457654", facebook_id: "peoplefinder", phone: "5646776465" }
        response = PeopleFinder.find(hsh)
        response.should == @user
        hsh = {email: "finder@people.com", twitter: "456457654", phone: "5646776465" }
        response = PeopleFinder.find(hsh)
        response.should == @user3
        hsh = {twitter: "456457654", phone: "5646776465" }
        response = PeopleFinder.find(hsh)
        response.should == @user2
    end

    it "should ignore non user ID keys " do
        hsh = {twitter: "456457654", phone: "5646776465", receiver_name: "Dont Red", provider_id: 21, provider_name: "yepp ignore"  }
        response = PeopleFinder.find(hsh)
        response.should == @user2
    end


end