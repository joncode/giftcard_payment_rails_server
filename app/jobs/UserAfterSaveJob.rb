class UserAfterSaveJob

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterSaveJob.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)
		if user
			RedisWrap.set_profile(user_id, user.login_client_serialize)
		end

	end

end