class AddDetailToGiftItems < ActiveRecord::Migration
  def up
    add_column    :gift_items, :detail, :text
  end

  def down
    remove_column :gift_items, :detail
  end
end
