class AddIndexToGiftIdOnOrdersAndSales < ActiveRecord::Migration
  def up
  	add_index :orders, :gift_id
  	add_index :sales, :provider_id
  end

  def down
  	remove_index :orders, :gift_id
  	remove_index :sales, :provider_id
  end
end
