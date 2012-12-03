class CreateGiftsMenusJoinTable < ActiveRecord::Migration
  	def change
		create_table :gifts_menus, id: false do |t|
			t.integer :gift_id
			t.integer :menu_id
		end

		add_index :gifts_menus, :gift_id
		add_index :gifts_menus, :menu_id
  	end
end
