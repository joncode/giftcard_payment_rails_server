require 'spec_helper'

describe BizUser do

    it_should_behave_like "giver ducktype" do
        let(:object) { FactoryGirl.create(:provider).biz_user }
    end

    it "builds from factory" do
        provider = FactoryGirl.create :provider
        biz_user = provider.biz_user
        biz_user.should be_valid
    end

    it "should get name and ID from provider" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)

        biz_user.class.should == BizUser
        biz_user.id.should    == provider.id
        biz_user.name.should  == "#{provider.name} Staff"
    end

    it "should get adjusted provider name for name" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        biz_user.name.should == "#{provider.name} Staff"
    end

    it "should respond to get_photo with provider photo" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        photo = provider.get_photo
        biz_user.get_photo.should == photo
    end

    it "should associate with a gift as giver" do
        provider = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        gift     = FactoryGirl.build(:gift)
        gift.giver = biz_user
        gift.save

        biz_user.sent.first.id.should          == gift.id
        biz_user.sent.first.class.should       == Gift
        biz_user.sent.first.giver_name.should  == "#{provider.name} Staff"
    end

    it "should associate with proto as giver" do
        provider    = FactoryGirl.create(:provider)
        biz_user = BizUser.find(provider.id)
        proto        = FactoryGirl.build(:proto)
        proto.giver  = biz_user
        proto.giver_name = biz_user.name
        proto.save

        biz_user.protos.first.id.should          == proto.id
        biz_user.protos.first.class.should       == Proto
        biz_user.protos.first.giver_name.should  == "#{provider.name} Staff"
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
#  id              :integer         not null, primary key
#  name            :string(255)     not null
#  zinger          :string(255)
#  description     :text
#  address         :string(255)
#  city            :string(32)
#  state           :string(2)
#  zip             :string(16)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#  phone           :string(255)
#  sales_tax       :string(255)
#  active          :boolean         default(TRUE)
#  latitude        :float
#  longitude       :float
#  rate            :decimal(, )     default(85.0)
#  menu_is_live    :boolean         default(FALSE)
#  brand_id        :integer
#  building_id     :integer
#  token           :string(255)
#  tools           :boolean         default(FALSE)
#  image           :string(255)
#  merchant_id     :integer
#  live            :boolean         default(FALSE)
#  paused          :boolean         default(TRUE)
#  pos_merchant_id :string(255)
#  region_id       :integer
#  r_sys           :integer         default(2)
#  photo_l         :string(255)
#  payment_plan    :integer         default(0)
#  payment_event   :integer         default(0)
#  tender_type_id  :string(255)
#  website         :string(255)
#

