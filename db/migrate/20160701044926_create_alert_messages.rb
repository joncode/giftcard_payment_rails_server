class CreateAlertMessages < ActiveRecord::Migration
  def change
    create_table :alert_messages do |t|
      t.integer :alert_contact_id
      t.integer :target_id
      t.string :target_type
      t.string :status, default: 'unsent'
      t.string :reason
      t.string :msg

      t.timestamps null: false
    end
  end
end
