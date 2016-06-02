class AddDeviceIdFormatInSessionTokens < ActiveRecord::Migration
	def up
		change_column :session_tokens, :device_id, :string
	end

	def down
		change_column :session_tokens, :device_id, :integer
	end
end
