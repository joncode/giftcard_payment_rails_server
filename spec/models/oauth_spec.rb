require 'spec_helper'


describe Oauth do

    it "builds from factory" do
        oauth = FactoryGirl.build :oauth
        oauth.should be_valid
    end

    it "requires gift_id" do
        oauth = FactoryGirl.build(:oauth, :gift_id => nil)
        oauth.should_not be_valid
        oauth.should have_at_least(1).error_on(:gift_id)
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

    it "associates with a gift" do
        gift  = FactoryGirl.create(:gift)
        oauth = FactoryGirl.build(:oauth, gift: gift)
        oauth.save
        oauth.gift.id.should           == gift.id
        oauth.gift.class.to_s.should   == "Gift"
        oauth.gift_id.should           == gift.id
        gift.oauth.should       == oauth
    end
    
end# == Schema Information
#
# Table name: oauths
#
#  id         :integer         not null, primary key
#  gift_id    :integer
#  token      :string(255)
#  secret     :string(255)
#  network    :string(255)
#  network_id :string(255)
#  handle     :string(255)
#  photo      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

