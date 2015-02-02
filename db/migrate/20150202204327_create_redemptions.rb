class CreateRedemptions < ActiveRecord::Migration
  def change
    create_table :redemptions do |t|
      t.integer :gift_id
      t.integer :amount, default: 0
      t.string :ticket_id
      t.json :req_json
      t.json :resp_json
      t.integer :type_of, default: 0
      t.integer :gift_prev_value, default: 0
      t.integer :gift_next_value, default: 0
      t.timestamps
    end

    add_index :redemptions, :gift_id
  end
end
