require 'spec_helper'
require 'expiration'

describe "Expiration" do

    describe :expire_gifts do
        before { Gift.delete_all }


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

    describe :destroy_sms_contacts do
        it "should destroy sms contacts with no gift that are more than a week old, with expired campaign item" do
            campaign    = FactoryGirl.create :campaign, close_date: 3.days.ago
            campaign_item = FactoryGirl.create :campaign_item, campaign_id: campaign.id, textword: "secret", expires_at: 1.week.ago

            new_nogift  = FactoryGirl.create :sms_contact, gift_id: nil, textword: "secret"
            old_nogift  = FactoryGirl.create :sms_contact, gift_id: nil, textword: "secret"
            old_hasgift = FactoryGirl.create :sms_contact, gift_id: 1, textword: "secret"
            old_nogift.update(created_at: 3.days.ago)
            old_hasgift.update(created_at: 3.days.ago)
            SmsContact.count.should == 3
            Expiration::destroy_sms_contacts
            SmsContact.count.should == 2
        end

        it "should not destroy any if campaign item is not yet expired" do
            today = Date.today
            campaign    = FactoryGirl.create :campaign, live_date: today, close_date: (today + 3.days)
            campaign_item = FactoryGirl.create :campaign_item, campaign_id: campaign.id, textword: "secret", expires_at: (today + 3.days)

            new_nogift  = FactoryGirl.create :sms_contact, gift_id: nil, textword: "secret"
            old_nogift  = FactoryGirl.create :sms_contact, gift_id: nil, textword: "secret"
            old_hasgift = FactoryGirl.create :sms_contact, gift_id: 1, textword: "secret"
            old_nogift.update(created_at: 3.days.ago)
            old_hasgift.update(created_at: 3.days.ago)
            SmsContact.count.should == 3
            Expiration::destroy_sms_contacts
            SmsContact.count.should == 3
        end

    end

end