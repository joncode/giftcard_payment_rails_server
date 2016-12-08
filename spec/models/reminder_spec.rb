require 'spec_helper'

describe Reminder do

	before(:all) do
		@abe = FactoryGirl.create :user, first_name: "abe"
		@bob = FactoryGirl.create :user, first_name: "bob"
		@cam = FactoryGirl.create :user, first_name: "cam"
		@provider = FactoryGirl.create :merchant, active: true, mode: "live"
		@bad_provider = FactoryGirl.create :merchant, mode: "Not Live"
	end

	after(:all) do
		User.delete_all
		Merchant.delete_all
	end



	context "3 day old gifts" do

	    it "should send email if just over 3 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.1.days
	    	MailerJob.should_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should send email if just under 4 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.9.days
	    	MailerJob.should_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if less than 3 or more than 4 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 2.days
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 4.days
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should send one email a person with multiple 3 day old gifts" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.5.days
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.5.days
	    	MailerJob.should_receive(:reminder_gift_receiver).once.and_return(true)
	    	Reminder.gift_reminder
		end

	    it "should not send email if not open notified or incomplete " do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.1.days, status: "redeemed"
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if provider is not live" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @bad_provider.id, created_at: today - 3.1.days
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end
	end

	context "10 day old gifts" do

	    it "should send email if 10.1 days old" do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 10.1.days, status: "incomplete"
	    	MailerJob.should_receive(:reminder_gift_giver).with(@abe, @bob.name).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should send email if 10.9 days old" do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 10.9.days, status: "incomplete"
	    	MailerJob.should_receive(:reminder_gift_giver).with(@abe, @bob.name).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email 9 - 11 days old" do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 9.days, status: "incomplete"
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 11.days, status: "incomplete"
	    	MailerJob.should_not_receive(:reminder_gift_giver).with(@abe, @bob.name).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if not open notified or incomplete " do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 10.1.days, status: "redeemed"
	    	MailerJob.should_not_receive(:reminder_gift_giver).with(@abe).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if provider is not live" do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @bad_provider.id, created_at: today - 10.1.days, status: "incomplete"
	    	MailerJob.should_not_receive(:reminder_gift_giver).with(@abe).and_return(true)
	    	Reminder.gift_reminder
	    end
	end

	context "30 day old gifts" do

	    it "should send email if just over 30 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.1.days, status: "open"
	    	MailerJob.should_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should send email if just under 31 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.9.days, status: "open"
	    	MailerJob.should_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if less than 30 or more than 31 days old" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 29.days, status: "open"
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 31.days, status: "open"
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should send one email to person with multiple 30 day old gifts" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.5.days, status: "open"
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.5.days, status: "open"
	    	MailerJob.should_receive(:reminder_gift_receiver).once.and_return(true)
	    	Reminder.gift_reminder
		end

	    it "should send one email to person with both 3 and 30 day old gifts" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 3.5.days, status: "open"
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.5.days, status: "open"
	    	MailerJob.should_receive(:reminder_gift_receiver).once.and_return(true)
	    	Reminder.gift_reminder
		end

	    it "should not send email if not open notified or incomplete " do
			today = Time.now.beginning_of_day
			Gift.skip_callback(:create, :before, :set_status_and_pay_stat)
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @provider.id, created_at: today - 30.1.days, status: "redeemed"
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end

	    it "should not send email if provider is not live" do
			today = Time.now.beginning_of_day
			FactoryGirl.create :gift, giver: @abe, receiver: @bob, merchant_id: @bad_provider.id, created_at: today - 30.1.days
	    	MailerJob.should_not_receive(:reminder_gift_receiver).with(@bob).and_return(true)
	    	Reminder.gift_reminder
	    end
	end

end