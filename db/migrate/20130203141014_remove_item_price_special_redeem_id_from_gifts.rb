class RemoveItemPriceSpecialRedeemIdFromGifts < ActiveRecord::Migration
  def up
  	remove_column :gifts, :category
  	remove_column :gifts, :price
  	remove_column :gifts, :item_id
  	remove_column :gifts, :item_name
  	remove_column :gifts, :special_instructions
  	remove_column :gifts, :redeem_id
  end

  def down
  	add_column :gifts, :category, :string
  	add_column :gifts, :price, :string
  	add_column :gifts, :item_id, :integer
  	add_column :gifts, :item_name, :string
  	add_column :gifts, :special_instructions, :text
  	add_column :gifts, :redeem_id, :integer
  end
end


# :category, :price, :item_id, :item_name, :special_instructions. :redeem_id
