class Reminder
	include Emailer

    def self.gift_reminder
        puts "----------------------Reminder Cron --------------------------"

        Gift.where(status: ["incomplete", "open", "notified"]).where('cat >= 300').find_each do |gift|
            [3,12,30,90,180,300].each do |d|

                if d < 30 && gift.status != 'incomplete'
                    next
                end

                if gift.created_at < d.days.ago && gift.created_at > (d + 1).days.ago

                    if gift.pending_redemptions.where(type_of: 3).first
                        break
                    end

                    puts "reminder for gift ID = #{gift.id}"
                    if gift.merchant.active_live?
                        if gift.receiver
                            gift.remind_receiver if gift.receiver.not_suspended?
                        else
                            gift.remind_receiver
                        end
                    end
                    break
                elsif gift.created_at > d.days.ago
                    break
                end
            end

        end

        puts "---------------------- end reminders ---------------------------"
    end


end

