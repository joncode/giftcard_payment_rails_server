class CollectIncompleteGiftsJob

    @queue = :after_save

    def self.perform user_id
    	raise "Method Argument must be an integer" if user_id.to_i == 0

    	user = User.find(user_id)

		gifts = []
		if user.facebook_id
			g = Gift.where("status = :stat AND facebook_id = :fb_id", :stat => 'incomplete', :fb_id   => user.facebook_id.to_s)
			gifts.concat g
		end
		if user.twitter
			g = Gift.where("status = :stat AND twitter = :tw", :stat => 'incomplete', :tw  => user.twitter.to_s)
			gifts.concat g
		end
		if user.email
			g = Gift.where("status = :stat AND receiver_email = :em", :stat => 'incomplete', :em  => user.email)
			gifts.concat g
		end
		if user.phone
			g = Gift.where("status = :stat AND receiver_phone = :phone", :stat => 'incomplete', :phone   => user.phone.to_s)
			gifts.concat g
		end

						# update incomplete gifts to open gifts with receiver info
		response   = if gifts.count > 0
			error   = 0
			success = 0

			gifts.each do |g|
				gift_changes                  = {}
				gift_changes[:status]         = "open"
				gift_changes[:receiver_phone] = user.phone if user.phone
				gift_changes[:receiver_email] = user.email if user.email
				gift_changes[:receiver_id]    = user.id
				gift_changes[:receiver_name]  = user.username

				if g.update(gift_changes)
					success += 1
					PushJob.perform(g.id, true, true)
				else
					error   += 1
				end
			end
							# build success & error messages for reference
			if  error  == 0
				"#{success} incomplete gift(s) updated SUCCESSfully on create of #{user.username} #{user.id}"
			else
				"#{error} ERRORS updating ghost gifts for #{user.username} #{user.id}"
			end

		else
							# no incomplete gifts found
			 "ZERO incomplete ghost gifts for  #{user.username} #{user.id}"
		end

							# log the messages output for the method
		puts response

    end

end