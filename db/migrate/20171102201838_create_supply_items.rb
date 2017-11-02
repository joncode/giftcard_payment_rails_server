class CreateSupplyItems < ActiveRecord::Migration
  def change
    create_table :supply_items do |t|
      t.string :hex_id
      t.string :name
      t.integer :price
      t.string :ccy, default: 'USD'
      t.string :detail
      t.string :photo_url
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
