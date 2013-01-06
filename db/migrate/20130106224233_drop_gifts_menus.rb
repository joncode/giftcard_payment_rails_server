class DropGiftsMenus < ActiveRecord::Migration
  def up
  	drop_table :gifts_menus
  end

  def down
	create_table :gifts_menus, id: false do |t|
		t.integer :gift_id
		t.integer :menu_id
	end
  end
end
