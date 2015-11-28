namespace :reminders do

    task gift_reminder: :environment do
    	Reminder.gift_reminder
	end

	task internal: :environment do
		ReminderInternal.send_reminders
	end

	task incomplete_gifts: :environment do
		ReminderIncompleteGifts.perform
	end

end