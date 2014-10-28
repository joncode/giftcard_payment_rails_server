class ConfirmEmailJob

    @queue = :after_save

    def self.perform user_id, email
		unless Rails.env.development?
			if email
				if user = User.find(user_id)
					user.set_confirm_email
					user.confirm_email
				end
			else
				puts "User created without EMAIL !! #{self.id}"
			end
		end
    end

end