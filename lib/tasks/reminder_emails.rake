namespace :reminders do

	task internal: :environment do
		ReminderInternal.send_reminders
	end

	task incomplete_gifts: :environment do
		Reminder.gift_reminder
	end

end