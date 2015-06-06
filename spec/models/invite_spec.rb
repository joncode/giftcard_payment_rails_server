require 'spec_helper'

# include GiftModelFactory
include MerchantFactory

describe Invite do

    # it_should_behave_like "company ducktype" do
    #     let(:object) { FactoryGirl.build(:gift) }
    # end

	it "builds from factory" do
		invite = FactoryGirl.build :invite
		invite.should be_valid
		invite.save
	end

    it "should respond to :company" do
        m = make_merchant_provider('Test Invite')
        invite = FactoryGirl.create :invite, company_id: m.id, company_type: 'Merchant'
        invite.should be_valid
        invite.company.should == m
    end

    it "should respond to :mt_user, :merchants, :companies" do
        mtu = FactoryGirl.create(:mt_user)
        m = make_merchant_provider('Test Invite')
        invite = FactoryGirl.create :invite, company_id: m.id, company_type: 'Merchant', mt_user_id: mtu.id
        invite.should be_valid
        invite.mt_user.should == mtu
        mtu.merchants.first.should == m
        mtu.companies.first.should == m
    end


    it "should respond to :affiliates , :companies adn allow mtu user admins to be global" do
        mtu = FactoryGirl.create(:mt_user)
        m = FactoryGirl.create(:affiliate)
        two = FactoryGirl.create(:affiliate)
        three = FactoryGirl.create(:affiliate)
        merch = make_merchant_provider('Test Invite')
        invite = FactoryGirl.create :invite, company_id: m.id, company_type: 'Affiliate', mt_user_id: mtu.id
        invite.should be_valid
        invite.mt_user.should == mtu
        mtu.affiliates.first.should == m
        mtu.companies.first.should == m
        mtu.companies.count.should == 1

        mtu.update(admin: true)
        mtu.affiliates.first.should == m
        mtu.affiliates.count.should == 3

        expect( mtu.companies).to include(m)
        mtu.companies.count.should == 4

    end
end