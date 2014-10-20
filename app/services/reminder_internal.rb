class ReminderInternal

    def self.send_reminders
        puts "---------------------- Start Internal Reminder Cron --------------------------"
        self.expiring_campaign_reminder
        puts "---------------------- End Internal Reminder Cron ---------------------------"
    end

	def self.expiring_campaign_reminder
		today = Time.now.utc.to_date
		reminder_deadline = today + 2.days
		live_campaigns = Campaign.where("live_date <= ?", today).where("close_date >= ?", today)
		live_campaigns.each do |campaign|
			if campaign.close_date <= reminder_deadline
				data = {
					subject: "Campaign Expiration Notice",
					text: "Campaign #{campaign.name} is expiring within 2 days",
					email: HELP_CONTACT["email"]
				}
				self.route_email_system(data)
			end
		end
	end

private

	def self.route_email_system data
		if Rails.env.production? || Rails.env.test?
			puts "data in ReminderInternal.rb"
			Resque.enqueue(MailerInternalJob, data)
		end
	end

end