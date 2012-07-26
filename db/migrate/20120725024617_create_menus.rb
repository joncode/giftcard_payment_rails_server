class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
      t.integer :provider_id
      t.integer :item_id
      t.decimal :price
      t.integer :position

      t.timestamps
    end
  end
end
