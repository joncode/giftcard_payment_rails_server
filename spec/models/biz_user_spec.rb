require 'spec_helper'

describe BizUser do

    it "builds from factory" do
        provider = FactoryGirl.create :provider
        biz_user = provider.biz_user
        biz_user.should be_valid
    end

    it "should get adjusted provider name for name" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        biz_user.name.should == "#{provider.name} Staff"
    end

    it "should associate with a biz_user as giver" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        gift     = FactoryGirl.create(:gift, giver: biz_user)

        biz_user.sent.first.id.should          == gift.id
        biz_user.sent.first.class.should       == Gift
        biz_user.sent.first.giver_name.should  == "#{provider.name} Staff"
    end

    it "should get name and ID from provider" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)

        biz_user.class.should == BizUser
        biz_user.id.should    == provider.id
        biz_user.name.should  == "#{provider.name} Staff"
    end

    it "should associate with Debts" do
        provider = FactoryGirl.create(:provider)
        biz_user = provider.biz_user
        debt = FactoryGirl.create(:debt, owner: biz_user)
        biz_user.debts.first.class.should == Debt
        biz_user.debts.where(id: debt.id).count.should == 1
    end

    it "should create debt with service fee only" do
        provider = FactoryGirl.create(:provider)
        biz_user = provider.biz_user
        debt = biz_user.incur_debt("100.00")
        debt.amount.to_f.should == 15.0
        debt = biz_user.incur_debt("131")
        debt.amount.to_f.should == 19.65
    end
end


# == Schema Information
#
# Table name: providers
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

