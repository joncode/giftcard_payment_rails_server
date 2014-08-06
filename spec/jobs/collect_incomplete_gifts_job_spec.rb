require 'spec_helper'

include MockAndStubs   # gives the :relay_stubs method - email and push stubs

describe CollectIncompleteGiftsJob do

    describe :perform do

        before(:each) do
            relay_stubs
        end

        it "should accept the user_id" do
            user = FactoryGirl.create(:user, facebook_id: "654654654654")
            expect { CollectIncompleteGiftsJob.perform(user.id) }.to_not raise_error
            expect { CollectIncompleteGiftsJob.perform() }.to raise_error
            expect { CollectIncompleteGiftsJob.perform({:user => 1}) }.to raise_error
        end

        it "should associate the user with any incomplete gifts for facebook and send giver push" do
            gift = FactoryGirl.create(:gift, facebook_id: "654654654654", receiver_id: nil)
            user = FactoryGirl.create(:user, facebook_id: "654654654654")
            stub_incomplete_push gift.giver.ua_alias, user.username
            run_delayed_jobs
            gift.reload
            gift.status.should        == 'open'
            gift.receiver_id.should   == user.id
            gift.receiver_name.should == user.username
        end

        it "should associate the user with any incomplete gifts for twitter and send giver push" do
            gift = FactoryGirl.create(:gift, twitter: "654654654654", receiver_id: nil)
            user = FactoryGirl.create(:user, twitter: "654654654654")
            stub_incomplete_push gift.giver.ua_alias, user.username
            run_delayed_jobs
            gift.reload
            gift.status.should        == 'open'
            gift.receiver_id.should   == user.id
            gift.receiver_name.should == user.username

        end

        it "should associate the user with any incomplete gifts for email and send giver push" do
            gift = FactoryGirl.create(:gift, receiver_email: "tester@example.com", receiver_id: nil)
            user = FactoryGirl.create(:user, email: "tester@example.com")
            stub_incomplete_push gift.giver.ua_alias, user.username
            run_delayed_jobs
            gift.reload
            gift.status.should        == 'open'
            gift.receiver_id.should   == user.id
            gift.receiver_name.should == user.username

        end

        it "should associate the user with any incomplete gifts for phone and send giver push" do
            gift = FactoryGirl.create(:gift, receiver_phone: "2123456789", receiver_id: nil)
            user = FactoryGirl.create(:user, phone: "2123456789")
            stub_incomplete_push gift.giver.ua_alias, user.username
            run_delayed_jobs
            gift.reload
            gift.status.should        == 'open'
            gift.receiver_id.should   == user.id
            gift.receiver_name.should == user.username

        end

        it "should sent user a have received x amount of bulk gifts push" do

        end


    end
end