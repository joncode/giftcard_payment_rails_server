require 'spec_helper'

describe Reminder do

	before(:all) do
		@abe = FactoryGirl.create :user, first_name: "abe"
		@bob = FactoryGirl.create :user, first_name: "bob"
		@cam = FactoryGirl.create :user, first_name: "cam"
		@provider = FactoryGirl.create :provider, active: true, mode: "live"
		FactoryGirl.create :gift, giver: @abe, receiver: @bob, provider_id: @provider.id, created_at: 31.days.ago
		FactoryGirl.create :gift, giver: @abe, receiver: @cam, provider_id: @provider.id, created_at: 31.days.ago
		FactoryGirl.create :gift, giver: @bob, receiver: @cam, provider_id: @provider.id, created_at: 31.days.ago

		bad_gift_1 = FactoryGirl.create :gift, giver: @abe, receiver: @bob, provider_id: @provider.id, created_at: 31.days.ago
		bad_gift_1.update_attribute(:status, "incomplete")
		bad_gift_2 = FactoryGirl.create :gift, giver: @abe, receiver: @bob, provider_id: @provider.id, status: "open", created_at: 29.days.ago
	end
	after(:all) do
		User.delete_all
		Gift.delete_all
	end

    it "should send correct emails" do
    	MailerJob.should_receive(:send_reminder_gift_unopened).with(@abe).and_return(true)
    	MailerJob.should_receive(:send_reminder_gift_unopened).with(@bob).and_return(true)
    	MailerJob.should_receive(:send_reminder_unused_gift).with(@bob).and_return(true)
    	MailerJob.should_receive(:send_reminder_unused_gift).with(@cam).and_return(true)
    	Reminder.gift_reminder
    end

end