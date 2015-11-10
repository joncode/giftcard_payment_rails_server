class UserAfterCreateEvent

	@queue = :after_save

	def self.perform(user_or_user_id)
		puts "\n user #{user_or_user_id} is in UserAfterCreateEvent.rb\n"

		user = user_or_user_id.kind_of?(User) ? user_or_user_id : User.find(user_or_user_id)

		if user.client_id == 2
			puts "PTEG user created"
		end

	end

end