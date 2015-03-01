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
# == Schema Information
#
# Table name: affiliates
#
#  id                 :integer         not null, primary key
#  first_name         :string(255)
#  last_name          :string(255)
#  email              :string(255)
#  phone              :string(255)
#  address            :string(255)
#  state              :string(255)
#  city               :string(255)
#  zip                :string(255)
#  url_name           :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  total_merchants    :integer         default(0)
#  payout_merchants   :integer         default(0)
#  total_users        :integer         default(0)
#  payout_users       :integer         default(0)
#  payout_links       :integer         default(0)
#  value_links        :integer         default(0)
#  value_users        :integer         default(0)
#  value_merchants    :integer         default(0)
#  purchase_links     :integer         default(0)
#  purchase_users     :integer         default(0)
#  purchase_merchants :integer         default(0)
#  company            :string(255)
#  website_url        :string(255)
#

