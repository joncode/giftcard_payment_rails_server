class AddUserToAlertContacts < ActiveRecord::Migration
	def change
		add_column :users, :user_id, :integer
		add_column :users, :user_type, :string
		add_column :alerts, :title, :string
		add_column :alerts, :detail, :string
	end
end
