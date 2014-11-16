require 'spec_helper'
include MocksAndStubs

describe PointsForCompletionJob do

    describe :perform do

        before(:each) do
            @provider = FactoryGirl.create(:provider, region_id: 3)
        end

        it "should not give points when you gift yourself" do
            user = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User",  receiver_name: user.name, receiver_id: user.id, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "1", redeemed_at: Time.now + 1.week, cat: 300
            gift.notify
            gift.redeem_gift
            gift.update(redeemed_at: (Time.now + 1.month))
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_nil
            ups = UserPoint.where(user_id: user.id)
            ups.count.should == 0
        end

        it "should not give points for a boomerang" do
            # make a regift sent by boomerang
            # put the  gift thru point system
            # no points should be awarded

            boom = FactoryGirl.create(:boomerang)
            @user     = FactoryGirl.create(:user)
            @receiver = FactoryGirl.create(:user)
            @old_gift = FactoryGirl.create(:gift, giver: @user, receiver_phone: "2152667474", receiver_name: "No Existo", receiver_id: @receiver.id, message: "Hey Join this app!", value: "201.00", cost: "187.3", service: '10.05', cat: 300)
            @gift_hsh = {}
            @gift_hsh["old_gift_id"]   = @old_gift.id
            GiftBoomerang.create(@gift_hsh)

            @old_gift.reload
            resp = PointsForCompletionJob.perform(@old_gift.id)
            resp.should be_nil
            ups = UserPoint.where(user_id: @user.id).count.should == 0
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
            rec = FactoryGirl.create(:user)
            gift = FactoryGirl.create :gift, giver_type: "User",  receiver_name: rec.name, receiver_id: rec.id, giver_id: user.id, payable_type: "Sale", status: "redeemed", provider_id: @provider.id, value: "1", redeemed_at: Time.now + 1.week, cat: 300
            receiver = FactoryGirl.create(:user, first_name: "Sarah", last_name: "Receiver")
            gift_hsh = {}
            gift_hsh["message"]       = "I just REGIFTED!"
            gift_hsh["name"]          = receiver.name
            gift_hsh["receiver_id"]   = receiver.id
            gift_hsh["giver"]         = user
            gift_hsh["old_gift_id"]   = gift.id
            new_g = GiftRegift.create(gift_hsh)
            resp = PointsForCompletionJob.perform(gift.id)
            resp.should be_true
            ups = UserPoint.where(user_id: user.id)
            ups.count.should == 2
            ups.first.points.should == 3000
        end
    end
end