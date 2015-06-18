class DevisifyMtUsers < ActiveRecord::Migration

	def up
			# missed this on previous devisify_at_user migration
		change_column_null(:at_users, :remember_token, true)

	  	change_column_null(:mt_users, :remember_token, true)
		MtUser.find_each do |user|
			resp = user.update_column(:encrypted_password, user.read_attribute(:password_digest))
			puts resp.inspect
		end

	end

	def down
			# missed this on previous devisify_at_user migration
		change_column_null(:at_users, :remember_token, false)

	  	change_column_null(:mt_users, :remember_token, false)
		MtUser.find_each do |user|
			resp = user.update_column(:password_digest, user.read_attribute(:encrypted_password))
			puts resp.inspect
		end

	end
end
