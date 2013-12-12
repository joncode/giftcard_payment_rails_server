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

    it "should web serialize with menu in json" do
        provider = FactoryGirl.create(:provider)
        FactoryGirl.create(:menu_string, provider_id: provider.id)
        p_hsh = provider.web_serialize
        p_hsh["name"].should        == provider.name
        p_hsh["city"].should        == provider.city
        p_hsh["phone"].should       == provider.phone
        p_hsh["latitude"].should    == provider.latitude
        p_hsh["longitude"].should   == provider.longitude
        p_hsh["provider_id"].should == provider.id
        p_hsh["photo"].should       == provider.get_photo
        p_hsh["full_address"].should == provider.full_address
        p_hsh["menu"].should         == JSON.parse(provider.menu_string.data)

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

