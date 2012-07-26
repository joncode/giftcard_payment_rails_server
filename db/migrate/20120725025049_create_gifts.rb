class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.integer :giver_id
      t.integer :receiver_id
      t.integer :item_id
      t.decimal :price
      t.integer :quantity
      t.decimal :total
      t.string  :credit_card
      t.integer :provider_id
      t.string  :message
      t.string  :special_instructions
      t.integer :redeem_id
      t.string  :status

      t.timestamps
    end
  end
end
