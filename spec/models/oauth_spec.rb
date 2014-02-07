require 'spec_helper'


describe Oauth do

    it "builds from factory" do
        oauth = FactoryGirl.build :oauth
        oauth.should be_valid
    end

    it "requires owner_id and owner_type" do
        oauth = FactoryGirl.build(:oauth, :owner_id => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:owner_id)
        oauth = FactoryGirl.build(:oauth, :owner_type => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:owner_type)
    end

    it "requires network" do
        oauth = FactoryGirl.build(:oauth, :network => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:network)
    end

    it "requires 'token'" do
        oauth = FactoryGirl.build(:oauth, :token => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:token)
    end

    it "requires 'secret' when network is twitter" do
        oauth = FactoryGirl.build(:oauth, :secret => nil, :network => "twitter")
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:secret)
    end

    context "owner polymorphic" do

        it "associates with a gift as owner" do
            gift  = FactoryGirl.create(:gift)
            oauth = FactoryGirl.build(:oauth, owner_type: "Gift", owner_id: gift.id)
            oauth.save
            oauth.owner.id.should           == gift.id
            oauth.owner.class.to_s.should   == "Gift"
            oauth.owner_id.should           == gift.id
            oauth.owner_type.should         == "Gift"
        end
    end


end