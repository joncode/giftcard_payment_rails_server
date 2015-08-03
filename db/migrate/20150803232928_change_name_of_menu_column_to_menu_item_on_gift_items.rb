class ChangeNameOfMenuColumnToMenuItemOnGiftItems < ActiveRecord::Migration
  def change
  	rename_column :gift_items, :menu_id, :menu_item_id
  end
end
