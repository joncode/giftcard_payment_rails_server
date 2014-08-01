module DestroyDuplicateGifts

    def self.perform provider_id=nil, created_after=nil
        puts "------------- DESTROY DUPLICATE GIFTS CRON -----------------"
    	gifts = Gift.where(provider_id: provider_id, receiver_id: nil).where("created_at > ?", created_after)
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

end