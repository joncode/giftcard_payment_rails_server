class CreateAlertContacts < ActiveRecord::Migration
  def change
    create_table :alert_contacts do |t|
      t.integer :note_id
      t.string :note_type
      t.integer :alert_id
      t.string :net
      t.string :net_id
      t.string :status, default: 'live'

      t.timestamps null: false
    end
  end
end
