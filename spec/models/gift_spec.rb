require 'spec_helper'


describe Gift do

    it "builds from factory" do
        gift = FactoryGirl.create :gift
        gift.should be_valid
    end

    it "requires giver" do
      gift = FactoryGirl.build(:gift, :giver => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:giver)
    end

    it "requires receiver_name" do
      gift = FactoryGirl.build(:gift, :receiver_name => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:receiver_name)
    end

    it "requires provider_id" do
      gift = FactoryGirl.build(:gift, :provider_id => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:provider_id)
    end

    it "requires total" do
      gift = FactoryGirl.build(:gift, :value => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:value)
    end

    it "requires shoppingCart" do
      gift = FactoryGirl.build(:gift, :shoppingCart => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:shoppingCart)
    end

    it "should save gift_items on create" do
      gift = FactoryGirl.build(:gift)
      gift.save
      items = JSON.parse gift.shoppingCart
      gift.gift_items.count.should == items.count
      gift.gift_items.first.menu_id.should == items.first["item_id"]
    end

    it "should save sale as payable on create" do
      gift = FactoryGirl.build(:gift)
      sale = FactoryGirl.build(:sale)
      gift.payable = sale
      gift.save
      saved_gift = Gift.last
      saved_gift.payable.should == Sale.last
    end

    it "should get the provider name if it does not have one" do
      gift = FactoryGirl.build(:gift, :provider_name => nil)
      gift.save
      gift.provider_name.should_not be_nil
    end

    describe :update do

      it "should extract phone digits" do
        gift = FactoryGirl.create(:gift)
        gift.update_attributes({ "receiver_phone" => "262-554-3628" })
        gift.reload
        gift.receiver_phone.should == "2625543628"
      end

    end

    it "should associate with a user as giver" do
        user = FactoryGirl.create(:user)
        gift = FactoryGirl.build(:gift)
        gift.giver = user
        gift.save
        gift.giver.id.should    == user.id
        gift.giver.name.should  == user.name
        gift.giver_name.should  == user.name
        gift.giver_id.should    == user.id
        gift.giver.class.should == User
    end

    it "should associate with a BizUser as giver" do
        biz_user = FactoryGirl.create(:provider).biz_user

        gift = FactoryGirl.create(:gift, giver: biz_user)

        gift.reload
        gift.giver.id.should    == biz_user.id
        gift.giver.name.should  == biz_user.name
        gift.giver.class.should == BizUser
    end

    it "should associate with a user as receiver" do
        user = FactoryGirl.create(:user)
        gift = FactoryGirl.create(:gift, receiver: user)

        gift.reload
        gift.receiver.id.should    == user.id
        gift.receiver.name.should  == user.name
        gift.receiver_name.should  == user.name
        gift.receiver_id.should    == user.id
        gift.receiver.class.should == User
    end

    it "should associate with provider" do
        provider = FactoryGirl.create(:provider)
        gift = FactoryGirl.create(:gift, provider: provider)

        gift.reload
        gift.provider.id.should    == provider.id
        gift.provider.name.should  == provider.name
        gift.provider_id.should    == provider.id
        gift.provider_name.should  == provider.name
        gift.provider.class.should == Provider
    end

    it "should associate with a Sale as payment" do
        sale = FactoryGirl.create(:sale)

        gift = FactoryGirl.build(:gift)
        gift.payable = sale
        gift.save

        gift.payable.id.should       == sale.id
        gift.payable.class.should    == Sale
        gift.payable.response.should == sale.response
    end

    it "should associate with a Debt as payment" do
        debt = FactoryGirl.create(:debt)

        gift = FactoryGirl.create(:gift, payable: debt)

        gift.reload
        gift.payable.id.should      == debt.id
        gift.payable.class.should   == Debt
    end

    it "should save the total as string" do
        gift = FactoryGirl.create(:gift, value: "100.00")
        gift.value.should == "100.00"
        gift.total.should == "100.00"
    end

end

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  total          :string(20)
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  tax            :string(255)
#  tip            :string(255)
#  regift_id      :integer
#  foursquare_id  :string(255)
#  facebook_id    :string(255)
#  anon_id        :integer
#  sale_id        :integer
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  stat           :integer
#  pay_stat       :integer
#  pay_type       :string(255)
#  pay_id         :integer
#  notified_at    :datetime
#  notified_at_tz :string(255)
#  redeemed_at    :datetime
#  redeemed_at_tz :string(255)
#  server_code    :string(255)
#

