require 'spec_helper'


describe Redeem do

    it "builds from factory" do
        redeem = FactoryGirl.create :redeem
        redeem.should be_valid
    end

    it "requires gift_id" do
      redeem = FactoryGirl.build(:redeem, :gift_id => nil)
      redeem.should_not be_valid
      redeem.should have_at_least(1).error_on(:gift_id)
    end

    it "validates uniqueness of gift_id" do
      previous = FactoryGirl.create(:order)
      order = FactoryGirl.build(:order, :gift_id => previous.gift_id)
      order.should_not be_valid
      order.should have_at_least(1).error_on(:gift_id)
      #order.errors.full_messages.should include("Validation msg about gift id")
    end

end



  # validates :gift_id   , presence: true, uniqueness: true