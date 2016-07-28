class AddActiveToAlertsAlertContactsAlertMessages < ActiveRecord::Migration
  def change
  	add_column :alerts, :active, :boolean, default: true
  	add_column :alert_contacts, :active, :boolean, default: true
  	add_column :alert_messages, :active, :boolean, default: true
  end
end
