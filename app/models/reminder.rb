class Reminder
	include Emailer

    def self.gift_reminder
    	gifts = Gift.where('status = :status1 OR status = :status2', { status1: "open", status2: "notified" }).where('created_at < ?', 30.days.ago)
    	users_with_received_gifts = []
    	users_with_sent_gifts = []
    	gifts.each do |gift|
    		if unused_gift? gift
    			users_with_received_gifts << gift.receiver_id unless users_with_received_gifts.include? gift.receiver_id
    			users_with_sent_gifts     << gift.giver_id    unless users_with_sent_gifts.include? gift.giver_id
			end
		end

		users_with_received_gifts.each do |uid|
			user = User.find(uid)
			MailerJob.send_reminder_unused_gift(user) if user.setting.gift_reminder == true
		end
		users_with_sent_gifts.each do |uid|
			user = User.find(uid)
			MailerJob.send_reminder_gift_unopened(user) if user.setting.gift_not_received == true
		end
	end


private

	def self.unused_gift? gift
    	provider = Provider.find(gift.provider_id)
    	if provider.active == true && provider.mode == "live" && (gift.status == "open" || gift.status == "notified")
    		true
    	else
    		false
    	end
	end


end