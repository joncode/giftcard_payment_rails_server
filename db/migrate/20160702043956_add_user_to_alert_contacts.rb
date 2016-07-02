class AddUserToAlertContacts < ActiveRecord::Migration
	def change
		add_column :alert_contacts, :user_id, :integer
		add_column :alert_contacts, :user_type, :string
		add_column :alerts, :title, :string
		add_column :alerts, :detail, :string
	end
end
