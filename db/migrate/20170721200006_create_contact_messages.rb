class CreateContactMessages < ActiveRecord::Migration
  def change
    create_table :contact_messages do |t|
      t.string :status, default: 'unsent'
      t.integer :contact_id
      t.integer :message_id
      t.datetime :redeemed_at
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
