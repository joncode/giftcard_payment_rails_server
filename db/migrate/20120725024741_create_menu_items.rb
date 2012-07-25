class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
      t.string  :item_name
      t.string  :detail
      t.integer :category

      t.timestamps
    end
  end
end
