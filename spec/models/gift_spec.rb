require 'spec_helper'


describe Gift do

    it "builds from factory" do
        user_social = FactoryGirl.create :gift
        user_social.should be_valid
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