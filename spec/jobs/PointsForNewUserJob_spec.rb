require 'spec_helper'
include MocksAndStubs

describe PointsForNewUserJob do

    describe :perform do

        before(:each) do
            @provider = FactoryGirl.create(:provider, region_id: 3)
        end

        it  "should return nil if receives an array of not applicatble gifts" do
            @admin_giver = FactoryGirl.create(:admin_user).giver
            gift = FactoryGirl.create(:gift, giver_type: "AdminGiver", giver_id: @admin_giver.id, payable_type: "Debt", status: "redeemed", provider_id: @provider.id, redeemed_at: Time.now + 1.week, cat: 100)
            resp = PointsForNewUserJob.perform([gift])
            resp.should be_nil
            ups = UserPoint.where(user_id: @admin_giver.id).count.should == 0
        end

        it "should give points only once to the first giver if multiple gifts go to a new user" do
            push_job_stubs
            resque_stubs
            user1 = FactoryGirl.create(:user)
            user2 = FactoryGirl.create(:user)
            user3 = FactoryGirl.create(:user)
            gift1 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user1.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            gift2 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user2.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            gift3 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user3.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300

            gift1.update(created_at: 1.month.ago)
            gift2.update(created_at: 1.week.ago)
            gift3.update(created_at: 1.day.ago)
            new_user = FactoryGirl.create(:user, facebook_id: "646464664466")
            us = UserSocial.find_by(identifier: "646464664466" )
            CollectIncompleteGiftsV2Job.perform(us.id)

            # PointsForNewUserJob.perform([gift1, gift2, gift3])

            UserPoint.where(user_id: user2.id).count.should == 0
            UserPoint.where(user_id: user3.id).count.should == 0
            ups = UserPoint.where(user_id: user1.id)
            ups.count.should == 2
            ups.first.points.should == 5000
        end

        it "should not give first user points multiple times" do
            push_job_stubs
            resque_stubs
            user1 = FactoryGirl.create(:user)
            user2 = FactoryGirl.create(:user)
            user3 = FactoryGirl.create(:user)
            gift1 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user1.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            gift2 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user2.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300

            gift1.update(created_at: 1.month.ago)
            gift2.update(created_at: 1.week.ago)

            new_user = FactoryGirl.create(:user, facebook_id: "646464664466")
            us = UserSocial.find_by(identifier: "646464664466" )
            CollectIncompleteGiftsV2Job.perform(us.id)
            UserPoint.where(user_id: user2.id).count.should == 0
            UserPoint.where(user_id: user3.id).count.should == 0
            ups = UserPoint.where(user_id: user1.id)
            ups.count.should == 2
            ups.first.points.should == 5000

            gift3 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, twitter: "646464466", receiver_name: "fab fb test", giver_id: user3.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            # PointsForNewUserJob.perform([gift1, gift2, gift3])
            gift3.update(created_at: 1.day.ago)
            new_user.update(twitter:"646464466")
            us = UserSocial.find_by(identifier: "646464466" )
            CollectIncompleteGiftsV2Job.perform(us.id)

            UserPoint.where(user_id: user2.id).count.should == 0
            UserPoint.where(user_id: user3.id).count.should == 0
            ups = UserPoint.where(user_id: user1.id)
            ups.count.should == 2
            ups.first.points.should == 5000
        end

        it "should not give points only once to the first giver if multiple gifts go to a new user if user pre-dates gifts" do
            push_job_stubs
            resque_stubs
            user1 = FactoryGirl.create(:user)
            user2 = FactoryGirl.create(:user)
            user3 = FactoryGirl.create(:user)
            gift1 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user1.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            gift2 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user2.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300
            gift3 = FactoryGirl.create :gift, giver_type: "User", receiver_name: "tet", receiver_id: nil, facebook_id: "646464664466", receiver_name: "fab fb test", giver_id: user3.id, payable_type: "Sale",  provider_id: @provider.id, value: "100", cat: 300

            gift1.update(created_at: (Time.now.utc + 1.month ))
            gift2.update(created_at: (Time.now.utc + 1.week ))
            gift3.update(created_at: (Time.now.utc + 1.day ))
            new_user = FactoryGirl.create(:user, facebook_id: "646464664466")
            us = UserSocial.find_by(identifier: "646464664466" )
            CollectIncompleteGiftsV2Job.perform(us.id)

            # PointsForNewUserJob.perform([gift1, gift2, gift3])

            UserPoint.where(user_id: user2.id).count.should == 0
            UserPoint.where(user_id: user3.id).count.should == 0
            ups = UserPoint.where(user_id: user1.id)
            ups.count.should == 0
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