namespace :db do

    task gift_reminder: :environment do
    	Reminder.gift_reminder
	end

end