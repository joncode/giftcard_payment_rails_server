class RemoveTimestampsFromGiftItems < ActiveRecord::Migration
  def up
    remove_column :gift_items, :created_at
    remove_column :gift_items, :updated_at
  end

  def down
    add_column :gift_items, :updated_at, :string
    add_column :gift_items, :created_at, :string
  end
end
