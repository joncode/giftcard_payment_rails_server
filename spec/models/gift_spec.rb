require 'spec_helper'


describe Gift do

    it "builds from factory" do
        gift = FactoryGirl.create :gift
        gift.should be_valid
    end

    it "requires giver_id" do
      gift = FactoryGirl.build(:gift, :giver_id => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:giver_id)
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
      gift = FactoryGirl.build(:gift, :total => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:total)
    end

    it "requires credit_card" do
      gift = FactoryGirl.build(:gift, :credit_card => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:credit_card)
    end

    it "requires service" do
      gift = FactoryGirl.build(:gift, :service => nil)
      gift.should_not be_valid
      gift.should have_at_least(1).error_on(:service)
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

    it "should save sale on create" do
      gift = FactoryGirl.build(:gift)
      sale = FactoryGirl.build(:sale)
      gift.sale = sale
      gift.save
      saved_gift = Gift.last
      saved_gift.sale.should == Sale.last

    end

    describe "collect incomplete gifts" do

      it "should collect gifts for any UserSocial account on user"

    end

    describe "#charge_card" do

    end



    # test that the gift starts as unpaid
    # test that the gift without the id after paid is incomplete
    # test that the gift with receiver id is open
    # test that when gift redeem is created that the gift status is notified
    # test that when the gift order is created that the gift is redeemed
    # test that the redeemed gift redeemed_at is the order time
    # test that when the gift is settled that the redeemed_at time is available
    # test that when the gift is voided that it is removed from the appropriate app lists
    # test that when the gift is refunded that it removed from the appropriate app lists

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

