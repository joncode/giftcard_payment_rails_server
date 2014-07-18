require 'spec_helper'

describe FriendPushJob do

    describe :perform do

        before(:each) do
            @current    = FactoryGirl.create(:user)
            @other_user = FactoryGirl.create(:user)
            @other2     = FactoryGirl.create(:user)
            @other3     = FactoryGirl.create(:user)
        end

        it "should send push users and update :pushed on each relationship" do
            Relationship.create(follower_id: @current.id, followed_id: @other_user.id)
            Relationship.create(follower_id: @current.id, followed_id: @other2.id)
            Relationship.create(follower_id: @current.id, followed_id: @other3.id)
            relates = Relationship.all
            relates.each do |r|
                r.pushed.should == false
            end

            Urbanairship.should_receive(:push).exactly(3).times
            FriendPushJob.perform(@current.id, 1)
            relates = Relationship.all
            relates.each do |r|
                r.pushed.should == true
            end
        end

        it "should send correct push content on each relationship" do
            Relationship.create(follower_id: @current.id, followed_id: @other_user.id)
            alert = "#{@current.username} can now send you a drink"
            push_content   = {
                :aliases => [@other_user.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => 0,
                    :sound => 'pn.wav'
                },
                :alert_type => 4,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(push_content).exactly(1).times
            FriendPushJob.perform(@current.id, 1)
        end

        it "should send joining user push of how many friends they have" do
            Relationship.create(follower_id: @other_user.id, followed_id: @current.id)
            Relationship.create(follower_id: @other2.id, followed_id: @current.id)
            Relationship.create(follower_id: @other3.id, followed_id: @current.id)
            relates = Relationship.all
            relates.each do |r|
                r.pushed.should == false
            end

            Urbanairship.should_receive(:push).exactly(1).times
            FriendPushJob.perform(@current.id, 2)
        end

        it "should send joining user push of how many friends they have" do
            Relationship.create(follower_id: @other_user.id, followed_id: @current.id)
            alert = "1 new friend can buy you a drink"
            push_content   = {
                :aliases => [@current.ua_alias],
                :aps => {
                    :alert => alert,
                    :badge => 0,
                    :sound => 'pn.wav'
                },
                :alert_type => 5,
                :android => {
                    :alert => alert
                }
            }
            Urbanairship.should_receive(:push).with(push_content).exactly(1).times
            FriendPushJob.perform(@current.id, 2)
        end
    end

end
