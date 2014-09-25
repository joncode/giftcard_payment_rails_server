require 'resque/plugins/resque_heroku_autoscaler'

class CollectIncompleteGiftsV2Job
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :after_save

    def self.perform user_social_id
    	puts "\n CollectIncompleteGiftsV2Job \n"
    	raise "Method Argument must be an integer" if user_social_id.to_i == 0

    	user_social = UserSocial.find(user_social_id)

    	case user_social.type_of
    	when 'email'
    		gifts = Gift.where(status: 'incomplete', receiver_email: user_social.identifier)
    	when 'phone'
    		gifts = Gift.where(status: 'incomplete', receiver_phone: user_social.identifier)
    	when 'facebook_id'
    		gifts = Gift.where(status: 'incomplete', facebook_id: user_social.identifier)
    	when 'twitter'
    		gifts = Gift.where(status: 'incomplete', twitter: user_social.identifier)
    	end

						# update incomplete gifts to open gifts with receiver info
		response   = if gifts.count > 0
			error   = 0
			success = 0

			user = user_social.user
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
			 "ZERO incomplete ghost gifts for  #{user_social.identifier} #{user_social.id}"
		end
		Ditto.collect_incomplete_gifts_create(response, user_social_id)
							# log the messages output for the method
		puts response

    end

end