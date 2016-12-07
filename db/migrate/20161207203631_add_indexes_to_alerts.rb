class AddIndexesToAlerts < ActiveRecord::Migration
	def change
		add_index :alert_messages, [:active, :alert_contact_id]
		add_index :alert_contacts, [:active, :alert_id]
		add_index :alert_contacts, [:active, :alert_id, :note_id]
		add_index :alert_contacts, [:alert_id, :user_id, :user_type]
		add_index :alerts, [:active, :system]
	end
end
