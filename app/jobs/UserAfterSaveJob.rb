class UserAfterSaveJob

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterSaveJob.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)
		if user.kind_of?(User)
			RedisWrap.set_profile(user.id, user.login_client_serialize)
			user.user_socials.each do |us|
				if us.active
					CollectIncompleteGiftsV2Job.peform(us.id)
				end
			end
		end

	end

end