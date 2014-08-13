require 'resque/plugins/resque_heroku_autoscaler'

class CollectIncompleteGiftsJob
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :after_save

    def self.perform user_id
    	raise "Method Argument must be an integer" if user_id.to_i == 0

    	user = User.find(user_id)
		gifts = []
		Gift.where(status: 'incomplete').find_each do |gift|

			if !gift.facebook_id.blank? && gift.facebook_id == user.facebook_id.to_s
				gifts << gift
			elsif !gift.receiver_email.blank? && gift.receiver_email == user.email
				gifts << gift
			elsif !gift.receiver_phone.blank? && gift.receiver_phone == user.phone
				gifts << gift
			elsif !gift.twitter.blank? && gift.twitter == user.twitter.to_s
				gifts << gift
			end

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
				"#{success} incomplete ghost gift(s) updated SUCCESSfully on create of #{user.username} #{user.id}"
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