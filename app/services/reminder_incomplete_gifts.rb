class ReminderIncompleteGifts

	def self.perform
		incomplete_reminded = 0
		seven_days_ago = DateTime.now.utc - 7.days
		day_seven = seven_days_ago.day
		day_twelve = (seven_days_ago - 5.days).day
        Gift.where(status: "incomplete").find_each do |gift|

        	if gift.created_at.day == day_seven || gift.created_at.day == day_twelve
                gift.notify_receiver
                "-------------  300 CRON Reminder Incomplete Gifts = #{gift.id}  -------------"
                incomplete_reminded += 1
            end
        end
        puts "------------- 300 CRON  #{incomplete_reminded} incomplete reminded gifts -----------------"
	end

end