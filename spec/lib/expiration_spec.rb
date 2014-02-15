require 'spec_helper'
require 'expiration'

describe "Expiration" do

    describe :expire_gifts do

        it "should expire gifts that are past expiration" do
            10.times do
                previous = Time.now - 1.days
                FactoryGirl.create(:gift, expires_at: previous)
            end
            Expiration::expire_gifts
            gs = Gift.all
            gs.each do |gift|
                gift.status.should == "expired"
            end
        end

        it "should not expire gifts that are before expiration" do
            10.times do
                previous = Time.now + 1.days
                FactoryGirl.create(:gift, expires_at: previous)
            end
            Expiration::expire_gifts
            gs = Gift.all
            gs.each do |gift|
                gift.status.should_not == "expired"
            end
        end

        it "should ignore gifts with nil expiration dates " do
            10.times do
                FactoryGirl.create(:gift, expires_at: nil)
            end
            Expiration::expire_gifts
            gs = Gift.all
            gs.each do |gift|
                gift.status.should_not == "expired"
            end
        end
    end

end