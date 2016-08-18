class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :owner_type
      t.integer :owner_id
      t.string :token
      t.boolean :active, default: true
      t.string :template
      t.string :name
      t.string :zinger
      t.text :detail
      t.string :photo
      t.string :logo
      t.integer :total_items
      t.string :item_types

      t.timestamps null: false
    end
  end
end
