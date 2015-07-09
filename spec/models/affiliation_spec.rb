require 'spec_helper'

describe Affiliation do


	it "should have status enum" do
        u = FactoryGirl.create(:user, first_name: "Test", last_name: "Biffet", city: "New Amsterdam")
        a = FactoryGirl.create(:affiliate)
        u.affiliate = a
        affiliation = u.affiliation
        affiliation.status.should == 'on'
        affiliation.on?.should be_true
	end

    it "should save user & affiliate data with affiliation creation" do
        u = FactoryGirl.create(:user, first_name: "Test", last_name: "Biffet", city: "New Amsterdam")
        a = FactoryGirl.create(:affiliate)
        u.affiliate = a
        u.affiliate.should == a
        affiliation = u.affiliation
        affiliation.name.should == "Test Biffet"
        affiliation.address.should == "New Amsterdam"

        u.reload
        a.reload
        u.affiliate_url_name.should == a.url_name
        a.total_users.should == 1
        a.total_merchants.should == 0
    end

    it "should save user & affiliate data with affiliation creation only" do
        u = FactoryGirl.create(:user, first_name: "Test", last_name: "Biffet", city: "New Amsterdam")
        a = FactoryGirl.create(:affiliate)
        u.affiliate = a
        u.affiliate.should == a
        affiliation = u.affiliation
        affiliation.name.should == "Test Biffet"
        affiliation.address.should == "New Amsterdam"

        u.reload
        a.reload
        u.affiliate_url_name.should == a.url_name
        a.total_users.should == 1
        a.total_merchants.should == 0

        affiliation.payout = 1040
        affiliation.save
        a.reload
        a.total_users.should == 1
    end

    it "should save merchant & affiliate data with affiliation creation" do
        u = FactoryGirl.create(:merchant, name: "Test",  city_name: "New Amsterdam")
        a = FactoryGirl.create(:affiliate)
        u.affiliate = a
        u.affiliate.should == a
        affiliation = u.affiliation
        affiliation.name.should == u.name
        affiliation.address.should == u.address

        u.reload
        a.reload
        u.affiliate_id.should == a.id
        a.total_users.should == 0
        a.total_merchants.should == 1
    end

    it "builds from factory" do
        affiliate = FactoryGirl.create :affiliation
        affiliate.should be_valid
    end
end
# == Schema Information
#
# Table name: affiliations
#
#  id           :integer         not null, primary key
#  affiliate_id :integer
#  target_id    :integer
#  target_type  :string(255)
#  name         :string(255)
#  address      :string(255)
#  payout       :integer         default(0)
#  status       :integer         default(0)
#  created_at   :datetime
#  updated_at   :datetime
#

