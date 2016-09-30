#require 'resque/plugins/resque_heroku_autoscaler'

class CollectIncompleteGiftsV2Job
    #extend Resque::Plugins::HerokuAutoscaler

    @queue = :aafter_save

    def self.perform user_social_id
    	puts "\n CollectIncompleteGiftsV2Job #{user_social_id}\n"
    	raise "Method Argument must be an integer" if user_social_id.to_i == 0

    	user_social = UserSocial.find(user_social_id)
		user = user_social.user

    	case user_social.type_of
    	when 'email'
    		gifts = Gift.where(status: 'incomplete', receiver_email: user_social.identifier)
    	when 'phone'
    		gifts = Gift.where(status: 'incomplete', receiver_phone: user_social.identifier)
    	when 'facebook_id'
    		gifts = Gift.where(status: 'incomplete', facebook_id: user_social.identifier)
    		gifts2 = self.match_facebook_gifts user
			gifts = gifts.to_a + gifts2
    	when 'twitter'
    		gifts = Gift.where(status: 'incomplete', twitter: user_social.identifier)
    	end

						# update incomplete gifts to open gifts with receiver info
		response = if gifts.count > 0
			error   = 0
			success = 0

			gifts.each do |g|
				gift_changes                  = {}
				gift_changes[:status]         = "open"
				gift_changes[:receiver_phone] = user.phone if user.phone
				gift_changes[:receiver_email] = user.email if user.email
				gift_changes[:receiver_id]    = user.id
				gift_changes[:receiver_name]  = user.username
				if user_social.type_of == 'facebook_id'
					gift_changes[:facebook_id] = user_social.identifier
				end

				if g.update(gift_changes)
					success += 1
					g.clear_caches
					GiftOpenedEvent.perform(g)
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

    def self.match_facebook_gifts user
		res = OpsFacebook.get_feed user
		if res['success'] == false
			return []
		else
			fd = res['data']
			fsmall = fd.select { |ff| ff['application'].present? && ff['application']['id'] == FACEBOOK_APP_ID && ff['link'].match(/acceptgift/) }
			if fsmall.count == 0
				return []
			else
				gift_ary = []
				fsmall.each do |ff|
					link = ff['link']
					our_url = link.split('?')[0]
					gift_id_str = our_url.match /\d+/
					if gift_id_str
						gift_ary << gift_id_str[0].to_i
					end
				end
				gift_ary.uniq!
				if gift_ary.count == 0
					return []
				else
					gifts = gift_ary.map { |ogi| Gift.find_with_obscured_id ogi }
					gifts_incomplete = gifts.select {|g| g.status == 'incomplete' }
					puts "Here is FB incomplete gifs #{gifts_incomplete.inspect} - #{gifts.count}"
					return gifts_incomplete
				end
			end
		end
    end

end