class AddMenuStringIdToMenus < ActiveRecord::Migration
  def change
    add_column :menus, :item_name,	 	:string
    add_column :menus, :photo,	 		:string
    add_column :menus, :description,	:string
    add_column :menus, :section, 		:string
  end
end
