class ReminderInternal

    def self.send_reminders
        puts "---------------------- Start Internal Reminder Cron --------------------------"
        self.expiring_campaign_reminder
        puts "---------------------- End Internal Reminder Cron ---------------------------"
    end

	def self.expiring_campaign_reminder
		today = Time.now.utc.to_date
		if Rails.env.staging?
			email = "support@itson.me"
		elsif Rails.env.production?
			email = "rachel.wenman@itson.me"
		end
		reminder_deadline = today + 2.days
		live_campaigns = Campaign.where("live_date <= ?", today).where("close_date >= ?", today)
		live_campaigns.each do |campaign|
			if campaign.close_date <= reminder_deadline
				data = {
					subject: "Campaign Expiration Notice",
					text: "Campaign #{campaign.id} is expiring within 2 days",
					email: email
				}
				self.route_email_system(data)
			else
				campaign.campaign_items.each do |ci|
					if ci.expires_at.present? && ci.expires_at <= reminder_deadline
						data = {
							subject: "Campaign Item Expiration Notice",
							text: "Campaign Item #{ci.id} for Campaign #{campaign.id} is expiring within 2 days",
							email: email
						}
						self.route_email_system(data)
					end
				end
			end
		end
	end

private

	def self.route_email_system data
		puts "data in ReminderInternal.rb"
		Resque.enqueue(MailerInternalJob, data)
	end

end