class RemoveSqlConstrantsFromMenu < ActiveRecord::Migration
  def up
  	#change_column_null(:menus, :provider_id, nil)
  	change_column_null(:menus, :item_id, nil)
  end

  def down
  end
end
