require 'spec_helper'

describe BizUser do

    it "builds from factory" do
        provider = FactoryGirl.create :provider
        biz_user = provider.biz_user
        biz_user.should be_valid
    end

    it "should repond to get_photo with provider photo" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        photo = provider.get_photo
        biz_user.get_photo.should == photo
    end

    it "should get adjusted provider name for name" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        biz_user.name.should == "#{provider.name} Staff"
    end

    it "should associate with a biz_user as giver" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        gift     = FactoryGirl.build(:gift)
        gift.giver = biz_user
        gift.save

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
#  id             :integer         not null, primary key
#  name           :string(255)     not null
#  zinger         :string(255)
#  description    :text
#  address        :string(255)
#  address_2      :string(255)
#  city           :string(32)
#  state          :string(2)
#  zip            :string(16)
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  phone          :string(255)
#  email          :string(255)
#  twitter        :string(255)
#  facebook       :string(255)
#  website        :string(255)
#  sales_tax      :string(255)
#  active         :boolean         default(TRUE)
#  latitude       :float
#  longitude      :float
#  foursquare_id  :string(255)
#  rate           :decimal(, )
#  menu_is_live   :boolean         default(FALSE)
#  brand_id       :integer
#  building_id    :integer
#  sd_location_id :integer
#  token          :string(255)
#  tools          :boolean         default(FALSE)
#  image          :string(255)
#  merchant_id    :integer
#  live           :boolean         default(FALSE)
#  paused         :boolean         default(TRUE)
#

