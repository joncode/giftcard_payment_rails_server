class AddIndexToProviderIdOnMenuStringsAndMenus < ActiveRecord::Migration
  def up
  	add_index :menu_strings, :provider_id
  	add_index :menus, :provider_id
  end

  def down
  	remove_index :menu_strings, :provider_id
  	remove_index :menus, :provider_id
  end
end
