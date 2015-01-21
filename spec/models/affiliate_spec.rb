require 'spec_helper'

describe Affiliate do

    it "builds from factory" do
        affiliate = FactoryGirl.create :affiliate
        affiliate.should be_valid
    end

    context "associations" do

        it "should respond to :merchants" do
            m = FactoryGirl.create(:merchant)
            a = FactoryGirl.create(:affiliate)
            a.merchants << m
            a.merchants.should == [m]
        end

        it "should respond to :users" do
            m = FactoryGirl.create(:user)
            a = FactoryGirl.create(:affiliate)
            a.users << m
            a.users.should == [m]
        end

        it "should respond to :payments" do
            a = FactoryGirl.create(:affiliate)
            m = FactoryGirl.create(:payment, partner_id: a.id, partner_type: 'Affiliate')
            a.payments << m
            a.payments.should == [m]
        end

        it "should respond to :affiliations" do
            a = FactoryGirl.create(:affiliate)
            m = FactoryGirl.create(:affiliation, affiliate_id: a.id)
            a.affiliations << m
            a.affiliations.should == [m]
        end

        it "should respond to :registers" do
            a = FactoryGirl.create(:affiliate)
            m = FactoryGirl.create(:register, partner_id: a.id, partner_type: 'Affiliate')
            a.registers << m
            a.registers.should == [m]
        end
    end
end
