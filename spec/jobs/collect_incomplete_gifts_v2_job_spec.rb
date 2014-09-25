require 'spec_helper'

include MockAndStubs   # gives the :relay_stubs method - email and push stubs

describe CollectIncompleteGiftsV2Job do

    describe :perform do

        before(:each) do
            resque_stubs
        end

        it "should accept the user_id" do
            user = FactoryGirl.create(:user, facebook_id: "654654654654")
            user_social = UserSocial.where(type_of: "facebook_id", identifier: "654654654654").first
            expect { CollectIncompleteGiftsV2Job.perform(user_social.id) }.to_not raise_error
            expect { CollectIncompleteGiftsV2Job.perform() }.to raise_error
            expect { CollectIncompleteGiftsV2Job.perform({:user => 1}) }.to raise_error
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

        context "do not connect these" do

            it "should not get gifts where the identifier is not the same" do
                gift = FactoryGirl.create(:gift, facebook_id: "12123456789", receiver_id: nil)
                user = FactoryGirl.create(:user, facebook_id: "2123456789")
                #stub_incomplete_push gift.giver.ua_alias, user.username
                run_delayed_jobs
                gift.reload
                gift.status.should_not        == 'open'
                gift.receiver_id.should_not   == user.id
                gift.receiver_name.should_not == user.username
            end

            it "should not get gifts where the identifier is not the same" do
                gift = FactoryGirl.create(:gift, receiver_phone: "2123456789", receiver_id: nil)
                user = FactoryGirl.create(:user, twitter: "2123456789")
                #stub_incomplete_push gift.giver.ua_alias, user.username
                run_delayed_jobs
                gift.reload
                gift.status.should_not        == 'open'
                gift.receiver_id.should_not   == user.id
                gift.receiver_name.should_not == user.username
            end

            it "should not get gifts where gift has already been gotten" do
                gift = FactoryGirl.create(:gift, receiver_phone: "2123456789", receiver_id: 123)
                user = FactoryGirl.create(:user, phone: "2123456789")
                #stub_incomplete_push gift.giver.ua_alias, user.username
                run_delayed_jobs
                gift.reload
                gift.status.should            == 'open'
                gift.receiver_id.should_not   == user.id
                gift.receiver_name.should_not == user.username
            end
        end

        it "should create a ditto" do
            Ditto.delete_all
            user = FactoryGirl.create(:user,
                facebook_id: "654654654654",
                twitter: "2123456789",
                phone: "2223334444",
                email: "ann@email.com")
            run_delayed_jobs
            Ditto.count.should == 4
            Ditto.first.cat.should == 3500
        end

    end
end