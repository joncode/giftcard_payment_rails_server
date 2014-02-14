class Reminder
	include Emailer

    def self.gift_reminder
    	today = Time.now.beginning_of_day
    	gifts = Gift.where(status: ["incomplete", "open", "notified"]).where('created_at > ?', today - 31.days)

    	thirtydaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 29.days)
    	thirtydaygifts.each do |gift|
    		if provider_active_and_live? gift
	    		user = User.where(id: gift.receiver_id).pop

                if user && user.not_suspended?
                    puts "here is 30 day for gift = #{gift.id}"
	    	        MailerJob.reminder_gift_receiver(user) if user.setting.email_reminder_gift_receiver == true
                end

	    	end
    	end

    	tendaygifts = gifts.where(status:["incomplete"]).where("created_at < ?", today - 10.days).where("created_at > ?", today - 11.days)
    	tendaygifts.each do |gift|
    		if provider_active_and_live? gift
	    		user = User.where(id: gift.giver_id).pop

                if user && user.not_suspended?
                    puts "here is 10 day for gift = #{gift.id}"
	    	        MailerJob.reminder_gift_giver(user, gift.receiver_name) if user.setting.email_reminder_gift_giver == true
                end
	    	end
    	end

    	threedaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 3.days).where("created_at > ?", today - 4.days)
    	threedaygifts.each do |gift|
    		if provider_active_and_live? gift
	    		user = User.where(id: gift.receiver_id).pop

                if user && user.not_suspended?
                    puts "here is 3 day for gift = #{gift.id}"
    		        MailerJob.reminder_gift_receiver(user) if user.setting.email_reminder_gift_receiver == true
                end
    		end
    	end
    end

private

	def self.provider_active_and_live? gift
		provider = gift.provider
		if provider.active == true && provider.mode == "live"
			true
		else
			false
		end
	end
end