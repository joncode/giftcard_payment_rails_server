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

    context "region id validation" do
        it "should reject provider without region id" do
            provider = FactoryGirl.build :provider, region_id: nil
            provider.should_not be_valid
            provider.errors.full_messages.first.should == "Region can't be blank"
        end
        it "should save region id to provider" do
            provider = FactoryGirl.create :provider, region_id: 15
            provider.should be_valid
            provider.region_id.should == 15
        end
    end

    context "socials associations" do
        it "should have many providers_socials" do
            provider = FactoryGirl.create :provider
            social1  = FactoryGirl.create :social
            social2  = FactoryGirl.create :social
            ps1      = FactoryGirl.create :providers_social, provider_id: provider.id, social_id: social1.id
            ps2      = FactoryGirl.create :providers_social, provider_id: provider.id, social_id: social2.id
            provider.providers_socials.count.should == 2
            provider.socials.count.should == 2
        end
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

