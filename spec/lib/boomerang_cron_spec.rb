require 'spec_helper'
require 'boomerang_cron'

describe "BoomerangCron" do

    describe :perform do

        before(:each) do
            @user = FactoryGirl.create(:user)
            @merchant = FactoryGirl.create(:provider)
            boom = FactoryGirl.create(:boomerang)
        end

        it "should boomerang gifts that are incomplete and older than 7 days" do
            previous = Time.now - 8.days
            10.times do
                FactoryGirl.create(:gift_no_association_with_card, created_at: previous, giver_name: @user.name, giver_id: @user.id, giver_type: "User", provider: @merchant)
            end

            BoomerangCron::perform
            gs = Gift.all
            gs.count.should == 20
            boomeranged_gifts = gs.where(status: 'regifted')
            boomeranged_gifts.count.should == 10
        end

        it "should not boomerang gifts that are incomplete and younger than 7 days" do
            10.times do
                previous = Time.now - 6.days

                FactoryGirl.create(:gift_no_association_with_card, created_at: previous, giver_name: @user.name, giver_id: @user.id, giver_type: "User", provider: @merchant)
            end

            BoomerangCron::perform
            gs = Gift.all
            gs.count.should == 10
            old_gifts = gs.where(status: 'regifted')
            old_gifts.count.should == 0
        end

        it "should ignore boomeranging gifts to deactivated users" do
            previous = Time.now - 8.days

            gift = FactoryGirl.create(:gift_no_association_with_card, created_at: previous, giver_name: @user.name, giver_id: @user.id, giver_type: "User", provider: @merchant)
            user = gift.giver
            user.update(active: false)

            BoomerangCron::perform
            gs = Gift.all
            gs.count.should == 1
            old_gifts = gs.where(status: 'regifted')
            old_gifts.count.should == 0
            gs.first.should == gift
        end
    end

end