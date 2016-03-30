class SessionBeginJob

	@queue = :cache

	def self.perform(client_id, user_or_user_id)

		client = Client.find(client_id)
		if client
			client.click
		end

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)
		if user
			RedisWrap.set_profile(user.id, user.login_client_serialize)
		end

	end


end