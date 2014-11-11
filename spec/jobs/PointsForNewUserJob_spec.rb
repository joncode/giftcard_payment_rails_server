require 'spec_helper'
include MocksAndStubs

describe PointsForNewUserJob do

    describe :perform do

        before(:each) do
            @provider = FactoryGirl.create(:provider, region_id: 3)
        end

        it "should reject any gift that is not a user purchase" do
            @admin_giver = FactoryGirl.create(:admin_user).giver

            gift = FactoryGirl.create(:gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: Time.now + 1.week, cat: 100)

            resp = PointsForNewUserJob.perform(gift.id)
            resp.should be_nil

            ups = UserPoint.where(user_id: @admin_giver.id).count.should == 0
        end

        it "should reject any gift that has no receiver_id" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            gift.receiver_id.should be_nil
            resp = PointsForNewUserJob.perform(gift.id)
            resp.should be_nil

            ups = UserPoint.where(user_id: user.id).count.should == 0
        end

        it "if gift was created before the user give points" do
            user = FactoryGirl.create(:user)
            rec = FactoryGirl.create(:user, created_at: (Time.now + 2.days))
            gift = FactoryGirl.create :gift, giver_type: "User",  receiver_name: rec.name, receiver_id: rec.id, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "1", redeemed_at: Time.now + 1.week, cat: 300
            gift.notify
            gift.redeem_gift
            resp = PointsForNewUserJob.perform(gift.id)
            resp.should be_true
            ups = UserPoint.where(user_id: user.id)
            ups.count.should == 2
            ups.first.points.should == 5000

        end
    end
end