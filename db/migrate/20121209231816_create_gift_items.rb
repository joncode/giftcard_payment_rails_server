class CreateGiftItems < ActiveRecord::Migration
  def change
    create_table :gift_items do |t|
      t.integer :gift_id
      t.integer :menu_id
      t.string  :price
      t.integer :quantity
      t.string  :name

      t.timestamps
    end

    add_index :gift_items, :gift_id
  end
end
