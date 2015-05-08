class DeviseifyAtUsers < ActiveRecord::Migration

	def up
	  	change_column_null(:users, :remember_token, true)
		AtUser.find_each do |user|
			resp = user.update_column(:encrypted_password, user.read_attribute(:password_digest))
			puts resp.inspect
		end

	end

	def down
	  	change_column_null(:users, :remember_token, false)
		AtUser.find_each do |user|
			resp = user.update_column(:password_digest, user.read_attribute(:encrypted_password))
			puts resp.inspect
		end

	end

end
