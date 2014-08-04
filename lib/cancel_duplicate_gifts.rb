module CancelDuplicateGifts

    def self.perform provider_id, created_after
        puts "------------- CANCEL DUPLICATE GIFTS CRON -----------------"
    	gifts = Gift.where(provider_id: provider_id, receiver_id: nil).where.not(status: 'cancel').where("created_at > ?", created_after)
	    duplicates_hsh = gifts.select(:receiver_email).group(:receiver_email).having("count(*) > 1").count
	    duplicates_hsh.each do |receiver_email, count|

        puts "**----------  START #{receiver_email} LOOP. #{count} copies"

	    	duplicate_gifts = gifts.where(receiver_email: receiver_email)[1..-1] # all gifts except for the first one in the array
	    	duplicate_gifts.each_with_index do |gift, index|
	    		gift.update(status: 'cancel', pay_stat: 'payment_error')
        puts "**------------- INSIDE #{receiver_email} LOOP updated #{index + 1} -----------------"
	    	end
        puts "**------------- END #{receiver_email} LOOP. -----------------"
	    end
        puts "------------- END DUPLICATE GIFTS CRON -----------------"
    end

    def self.undo_dual_cancels provider_id, created_after
        puts "------------- START UNDO DUAL CANCELS CRON -----------------"
        gifts = Gift.where(provider_id: provider_id, receiver_id: nil).where(status: 'cancel').where("created_at > ?", created_after)
        duplicates_hsh = gifts.select(:receiver_email).group(:receiver_email).having("count(*) > 1").count
        puts "-------- duplicates hash #{gifts.count}"
        puts "-------- duplicates hash #{duplicates_hsh}"
        duplicates_hsh.each do |receiver_email, count|
            duplicate_gift = gifts.where(receiver_email: receiver_email).first
            duplicate_gift.update(status: 'incomplete', pay_stat: 'charge_unpaid')
        puts "**------------- INSIDE #{receiver_email} updated -----------------"
        end
        puts "------------- END UNDO DUAL CANCELS CRON -----------------"
    end


    def self.find_duplicates provider_id, created_after
        puts "------------- START FINDING DUPLICATE GIFTS -----------------"
        gifts = Gift.where(provider_id: provider_id, receiver_id: nil).where.not(status: 'cancel').where("created_at > ?", created_after)
        duplicates_hsh = gifts.select(:receiver_email).group(:receiver_email).having("count(*) > 1").count
        puts duplicates_hsh
        puts "======== #{duplicates_hsh.count} total emails with duplicates."
        puts "------------- END FINDING DUPLICATE GIFTS -----------------"
    end

end


Gift.where(provider_id: 183, receiver_id: nil).where.not(status: 'cancel').where("created_at > ?", 1.day.ago).select(:receiver_email).group(:receiver_email).having("count(*) > 1").count.count