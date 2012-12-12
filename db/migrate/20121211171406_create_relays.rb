class CreateRelays < ActiveRecord::Migration
  def change
    create_table :relays do |t|
      t.integer :gift_id
      t.integer :giver_id
      t.integer :provider_id
      t.integer :receiver_id
      t.string  :status
      t.string  :name

      t.timestamps
    end

    add_index :relays, :receiver_id
    add_index :relays, :provider_id
    add_index :relays, :gift_id
  end
end
