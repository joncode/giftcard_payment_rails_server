namespace :db do

    task gift_reminder: :environment do
    	Reminder.gift_reminder
	end

	task internal_reminders: :environment do
		ReminderInternal.send_reminders
	end

end