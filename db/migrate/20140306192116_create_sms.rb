class CreateSms < ActiveRecord::Migration
  def change
    create_table :sms do |t|
      t.integer :gift_id
      t.datetime :subscribed_date
      t.string :phone
      t.integer :service_id
      t.string :service_type
      t.string :textword

      t.timestamps
    end
  end
end
