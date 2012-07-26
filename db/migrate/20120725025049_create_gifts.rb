class CreateGifts < ActiveRecord::Migration
  def change
    create_table :gifts do |t|
      t.integer :giver_id
      t.integer :receiver_id
      t.integer :item_id
      t.string  :price, limit: 20
      t.integer :quantity, null: false
      t.string  :total, limit: 20
      t.string  :credit_card, limit: 100
      t.integer :provider_id
      t.text    :message
      t.text    :special_instructions
      t.integer :redeem_id
      t.string  :status

      t.timestamps
    end
  end
end
