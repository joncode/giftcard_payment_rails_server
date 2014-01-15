require 'spec_helper'

describe Debt do

    it "builds from factory" do
        provider = FactoryGirl.create(:provider)
        biz_user = provider.biz_user
        debt = biz_user.incur_debt("10.00")
        debt.should be_valid
    end

    it "should associate with Gifts" do
        debt = FactoryGirl.create(:debt)

        gift = FactoryGirl.create(:gift, payable: debt)

        debt.reload
        debt.gift.id.should    == gift.id
        debt.gift.class.should == Gift
    end

    it "should associate with BizUser" do
        provider = FactoryGirl.create(:provider)
        biz_user = provider.biz_user
        debt     = biz_user.incur_debt("10.00")
        debt.owner.id.should    == biz_user.id
        debt.owner.class.should == biz_user.class
        debt.owner.name.should  == biz_user.name
    end

    it "should save the amount" do
        provider = FactoryGirl.create(:provider)
        biz_user = provider.biz_user
        debt     = FactoryGirl.create(:debt, owner: biz_user, amount: "10.00")
        debt.amount.should == BigDecimal("10.00")
    end

    it "should respond to #success?" do

        debt = FactoryGirl.create(:debt)
        debt.respond_to?(:success?).should be_true
    end


end


# == Schema Information
#
# Table name: debts
#
#  id         :integer         not null, primary key
#  owner_id   :integer
#  owner_type :string(255)
#  amount     :decimal(8, 2)
#  total      :decimal(8, 2)
#  detail     :string(255)
#  created_at :datetime
#  updated_at :datetime
#

