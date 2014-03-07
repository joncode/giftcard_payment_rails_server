class CreateSmsContacts < ActiveRecord::Migration
  def change
    create_table :sms_contacts do |t|
      t.integer :gift_id
      t.datetime :subscribed_date
      t.string :phone
      t.integer :service_id
      t.string :service
      t.string :textword

      t.timestamps
    end

    add_index :sms_contacts, :gift_id
    add_index :sms_contacts, :subscribed_date
  end
end
