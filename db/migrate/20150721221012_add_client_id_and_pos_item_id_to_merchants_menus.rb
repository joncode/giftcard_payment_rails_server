class AddClientIdAndPosItemIdToMerchantsMenus < ActiveRecord::Migration
  def change
  	add_column :merchants, :client_id, :integer
  	add_column :menu_items, :pos_item_id, :string
  	add_column :redemptions, :merchant_id, :integer
  end
end
