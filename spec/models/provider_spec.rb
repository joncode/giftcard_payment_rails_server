# require 'spec_helper'

# describe Provider do

#     it "builds from factory" do
#         provider = FactoryGirl.create :merchant
#         provider.should be_valid
#     end

#     it "should associate with many gifts as merchant" do
#         provider = FactoryGirl.create(:merchant)
#         gift = FactoryGirl.create(:gift, provider: provider)

#         provider.reload
#         provider.gifts.first.id.should          == gift.id
#         provider.gifts.first.class.should       == Gift
#     end

#     it "should return its BizUser" do
#         provider = FactoryGirl.create(:merchant)
#         biz_user = BizUser.find(provider.id)
#         provider.biz_user.should == biz_user
#     end

#     it "should return the location_fee" do
#         provider = FactoryGirl.create(:merchant)
#         provider.location_fee.should == 0.85
#         provider.update(payment_plan: :prime, rate: 95)
#         provider.location_fee.should == 0.95
#         provider.update(payment_plan: :choice, rate: 85)
#         provider.location_fee.should == 0.85
#     end

#     it "should web serialize with menu in json" do
#         provider = FactoryGirl.create(:merchant)
#         FactoryGirl.create(:menu_string, merchant_id: provider.id)
#         p_hsh = provider.web_serialize
#         p_hsh["name"].should       == provider.name
#         p_hsh["phone"].should      == provider.phone
#         p_hsh["latitude"].should   == provider.latitude
#         p_hsh["longitude"].should  == provider.longitude
#         p_hsh["region_id"].should  == provider.region_id
#         p_hsh["loc_id"].should     == provider.id
#         p_hsh["photo"].should      == provider.get_photo(default: false)
#         p_hsh["logo"].should       == provider.get_logo_web
#         p_hsh["loc_street"].should == provider.address
#         p_hsh["loc_city"].should   == provider.city_name
#         p_hsh["loc_state"].should  == provider.state
#         p_hsh["loc_zip"].should    == provider.zip
#         p_hsh["live"].should       == provider.live
#     end

#     context "region id validation" do
#         it "should reject provider without city id" do
#             provider = FactoryGirl.build :merchant, city_id: nil
#             provider.should_not be_valid
#             provider.errors.full_messages.first.should == "City can't be blank"
#         end
#         it "should save region id to provider" do
#             provider = FactoryGirl.create :merchant, region_id: 15
#             provider.should be_valid
#             provider.region_id.should == 15
#         end
#     end

#     context "socials associations" do
#         it "should have many providers_socials" do
#             provider = FactoryGirl.create :merchant
#             social1  = FactoryGirl.create :social
#             social2  = FactoryGirl.create :social
#             ps1      = FactoryGirl.create :providers_social, merchant_id: provider.id, social_id: social1.id
#             ps2      = FactoryGirl.create :providers_social, merchant_id: provider.id, social_id: social2.id
#             provider.providers_socials.count.should == 2
#             provider.socials.count.should == 2
#         end
#     end

# end

# # == Schema Information
# #
# # Table name: providers
# #
# #  id              :integer         not null, primary key
# #  name            :string(255)     not null
# #  zinger          :string(255)
# #  description     :text
# #  address         :string(255)
# #  city            :string(32)
# #  state           :string(2)
# #  zip             :string(16)
# #  created_at      :datetime        not null
# #  updated_at      :datetime        not null
# #  phone           :string(255)
# #  sales_tax       :string(255)
# #  active          :boolean         default(TRUE)
# #  latitude        :float
# #  longitude       :float
# #  rate            :decimal(, )
# #  menu_is_live    :boolean         default(FALSE)
# #  brand_id        :integer
# #  building_id     :integer
# #  token           :string(255)
# #  tools           :boolean         default(FALSE)
# #  image           :string(255)
# #  merchant_id     :integer
# #  live            :boolean         default(FALSE)
# #  paused          :boolean         default(TRUE)
# #  pos_merchant_id :string(255)
# #  region_id       :integer
# #  r_sys           :integer         default(2)
# #  photo_l         :string(255)
# #  payment_plan    :integer         default(0)
# #

