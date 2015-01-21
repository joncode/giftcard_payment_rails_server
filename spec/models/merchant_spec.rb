require 'spec_helper'

describe Merchant do

	context "associations" do

        it "should respond to :affiliate" do
            u = FactoryGirl.create(:merchant)
            a = FactoryGirl.create(:affiliate)
            u.affiliate = a
            u.affiliate.should == a
        end

        it "should respond to :affiliations" do
        	m = FactoryGirl.create(:merchant)
            a = FactoryGirl.create(:affiliation)
            m.affiliation = a
            m.affiliation.should == a
        end
	end
end
