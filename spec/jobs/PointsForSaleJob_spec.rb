require 'spec_helper'
include MocksAndStubs

describe PointsForSaleJob do

    describe :perform do

        before(:each) do
            @provider = FactoryGirl.create(:provider, region_id: 3)
        end

        it "should reject any gift that is not a user purchase" do
            @admin_giver = FactoryGirl.create(:admin_user).giver

            gift = FactoryGirl.create(:gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: Time.now + 1.week, cat: 100)

            resp = PointsForSaleJob.perform(gift.id)
            resp.should be_nil

            ups = UserPoint.where(user_id: @admin_giver.id).count.should == 0
        end

        it "should award points for a gift purchase and create user_point in region" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            resp = PointsForSaleJob.perform(gift.id)

            ups = UserPoint.where(user_id: user.id, region_id: @provider.region_id)
            ups.count.should == 1
            ups.first.points.should == 32000
        end

        it "should add the points to the total user_point as well" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            resp = PointsForSaleJob.perform(gift.id)

            ups = UserPoint.where(user_id: user.id, region_id: 0)
            ups.count.should == 1
            ups.first.points.should == 32000
        end

        it "should add 1000 points for facebook_id" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User",facebook_id: "2863912831", receiver_name: "fcbk tets", receiver_id: nil,  giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            resp = PointsForSaleJob.perform(gift.id)

            ups = UserPoint.where(user_id: user.id, region_id: 0)
            ups.count.should == 1
            ups.first.points.should == 33000

        end

        it "should add 1000 points for twitter" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User", twitter: "2863912831", receiver_name: "fcbk tets", receiver_id: nil,  giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "320", redeemed_at: Time.now + 1.week, cat: 300
            resp = PointsForSaleJob.perform(gift.id)

            ups = UserPoint.where(user_id: user.id, region_id: 0)
            ups.count.should == 1
            ups.first.points.should == 33000

        end

    end
end