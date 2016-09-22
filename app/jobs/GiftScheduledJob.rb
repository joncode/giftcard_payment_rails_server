class GiftScheduledJob

	def self.perform
        puts "------------- GiftScheduledJob CRON -----------------"
        sent_gifts = 0
        Gift.where(status: "schedule").where('scheduled_at < ?', DateTime.now.utc).find_each do |gift|

            begin
                if gift.schedule_gift
    	            "-------------  Scheduled gift ID = #{gift.id}  -------------"
    	            sent_gifts += 1
    	        else
    	        	"500 Internal - Scheduled gift failed #{gift.id} #{gift.errors.messages}"
    	        end
            rescue => e
                "500 Internal - Scheduled gift failed #{gift.id} #{e.inspect}"
            end

        end
        puts "------------- #{sent_gifts} Scheduled gifts sent -----------------"
    end

end

