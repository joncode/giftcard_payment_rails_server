class Reminder
	include Emailer

    def self.gift_reminder
        puts "----------------------Reminder Cron --------------------------"
        today = Time.now.beginning_of_day
        gifts = Gift.where(status: ["incomplete", "open", "notified"]).where('created_at > ?', today - 31.days)

        receivers_array = []
        thirtydaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 29.days)
        thirtydaygifts.each do |gift|
            print "reminder 30 day for gift = #{gift.id}"
            unless receivers_array.include? gift.receiver_id
                receivers_array << gift.receiver_id if provider_active_and_live? gift
            end
        end
        threedaygifts = gifts.where(status:["open", "notified"]).where("created_at < ?", today - 3.days).where("created_at > ?", today - 4.days)
        threedaygifts.each do |gift|
            print "reminder 3 day for gift = #{gift.id}"
            unless receivers_array.include? gift.receiver_id
                receivers_array << gift.receiver_id if provider_active_and_live? gift
            end
        end
        receivers_array.each do |id|
            receiver = User.find(id)
            MailerJob.reminder_gift_receiver(receiver) if receiver.setting.email_reminder_gift_receiver == true
        end


        tendaygifts = gifts.where(status:["incomplete"]).where("created_at < ?", today - 10.days).where("created_at > ?", today - 11.days)
        tendaygifts.each do |gift|
            print "reminder 10 day for gift = #{gift.id}"
            self.reminder_email_to_gift_user(gift, false)
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