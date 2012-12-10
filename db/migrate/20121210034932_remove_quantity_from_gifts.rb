class RemoveQuantityFromGifts < ActiveRecord::Migration
  def up
  	remove_column :gifts, :quantity
  end

  def down
  	add_column :gifts, :quantity, :integer
  end
end
