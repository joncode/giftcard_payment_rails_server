require 'spec_helper'
include MocksAndStubs

describe PointsForCompletionJob do

    describe :perform do

        before(:each) do
            @provider = FactoryGirl.create(:provider, region_id: 3)
        end

        it "should reject any gift that is not a user purchase" do
            @admin_giver = FactoryGirl.create(:admin_user).giver

            gift = FactoryGirl.create(:gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: Time.now + 1.week, cat: 100)

            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_nil

            ups = UserPoint.where(user_id: @admin_giver.id).count.should == 0
        end

        it "should reject any gift that is neither redeemed or regifted" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: 123, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            gift.notify
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_nil
            ups = UserPoint.where(user_id: user.id).count.should == 0

            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: 123, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_nil
            ups = UserPoint.where(user_id: user.id).count.should == 0
        end

        it "should accept a redeemed gift " do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User",  receiver_name: "tet", receiver_id: 123, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "1", redeemed_at: Time.now + 1.week, cat: 300
            gift.notify
            gift.redeem_gift
            gift.update(redeemed_at: (Time.now + 1.month))
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_true
            ups = UserPoint.where(user_id: user.id)
            ups.count.should == 2
            ups.first.points.should == 3000
        end

        it "should accept a regifted gift " do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User",  receiver_name: "tet", receiver_id: 123, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "1", redeemed_at: Time.now + 1.week, cat: 300
            gift.notify
            gift.redeem_gift
            gift.update(redeemed_at: (Time.now + 1.month), status: 'regifted')
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_true
            ups = UserPoint.where(user_id: user.id)
            ups.count.should == 2
            ups.first.points.should == 1000
        end
    end
end