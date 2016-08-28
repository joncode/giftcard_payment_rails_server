class Reminder
	include Emailer

    def self.gift_reminder
        puts "----------------------Reminder Cron --------------------------"

        Gift.where(status: ["incomplete", "open", "notified"]).find_each do |gift|

            if [3,7,12,21,30,60,90,120,150,180,210,240,270,300,330,360].includes?(gift.created_at.day)
                puts "reminder for gift ID = #{gift.id}"
                if gift.merchant_active_and_live? gift
                    if gift.receiver
                        gift.notify_receiver if gift.receiver.not_suspended?
                    else
                        gift.notify_receiver
                    end
                end
            end

        end

        puts "---------------------- end reminders ---------------------------"
    end

private

	def self.merchant_active_and_live? gift
		merchant = gift.merchant
		if merchant.active == true && merchant.mode == "live"
			true
		else
			false
		end
	end
end