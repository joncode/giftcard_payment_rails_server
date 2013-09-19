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

    describe "description" do

        it "should description" do

        end

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