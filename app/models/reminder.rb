class Reminder
	include Emailer

    def self.gift_reminder
        puts "----------------------Reminder Cron --------------------------"
    	today = Time.now.beginning_of_day
    	gifts = Gift.where(status: ["incomplete", "open", "notified"]).where('created_at > ?', today - 31.days)

    	thirtydaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 29.days)
    	thirtydaygifts.each do |gift|

            print "Reminder 30 day for gift = #{gift.id}"
    	    self.reminder_email_to_gift_user(gift)

    	end

    	tendaygifts = gifts.where(status:["incomplete"]).where("created_at < ?", today - 10.days).where("created_at > ?", today - 11.days)
    	tendaygifts.each do |gift|

            print "Reminder 10 day for gift = #{gift.id}"
            self.reminder_email_to_gift_user(gift, false)

    	end

    	threedaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 3.days).where("created_at > ?", today - 4.days)
    	threedaygifts.each do |gift|

            print "Reminder 3 day for gift = #{gift.id}"
            self.reminder_email_to_gift_user(gift)

    	end
        puts "---------------------- end reminders ---------------------------"
    end
    
private

    def self.reminder_email_to_gift_user(gift, receiver=true)
        if provider_active_and_live? gift
            user_id = receiver ? gift.receiver.id : gift.giver_id
            user = User.where(id: user_id).last
            if user && user.not_suspended?
                if receiver
                    puts " - sent receiver reminder"
                    MailerJob.reminder_gift_receiver(user) if user.setting.email_reminder_gift_receiver == true
                else
                    puts " - sent giver reminder"
                    MailerJob.reminder_gift_giver(user, gift.receiver_name) if user.setting.email_reminder_gift_giver == true
                end
            end
        end
    end

	def self.provider_active_and_live? gift
		provider = gift.provider
		if provider.active == true && provider.mode == "live"
			true
		else
			false
		end
	end
end