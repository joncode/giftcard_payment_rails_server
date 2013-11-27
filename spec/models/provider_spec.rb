require 'spec_helper'

describe Provider do

    it "builds from factory" do
        provider = FactoryGirl.create :provider
        provider.should be_valid
    end

    it "should associate with many gifts as merchant" do
        provider = FactoryGirl.create(:provider)
        gift = FactoryGirl.create(:gift, provider: provider)

        provider.reload
        provider.gifts.first.id.should          == gift.id
        provider.gifts.first.class.should       == Gift
    end

    it "should return its BizUser" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        provider.biz_user.should == biz_user
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

