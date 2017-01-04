class Reminder
	include Emailer

    def self.gift_reminder
        puts "----------------------Reminder Cron --------------------------"

        Gift.where(status: ["incomplete", "open", "notified"]).where('cat >= 300').find_each do |gift|
            [3,7,12,21,30,60,90,120,150,180,210,240,270,300,330,360].each do |d|

                if d < 30 && gift.status != 'incomplete'
                    next
                end

                if gift.created_at < d.days.ago && gift.created_at > (d + 1).days.ago

                    puts "reminder for gift ID = #{gift.id}"
                    if gift.merchant.active_live?
                        if gift.receiver
                            gift.notify_receiver if gift.receiver.not_suspended?
                        else
                            gift.notify_receiver
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

