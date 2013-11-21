class DropItemsmenusEmployeesConnectionsRelays < ActiveRecord::Migration
  def up
  	drop_table :items_menus
  	drop_table :employees
  	# drop_table :connections
  	drop_table :relays
  end

  def down

	create_table "items_menus", :id => false, :force => true do |t|
		t.integer "item_id"
		t.integer "menu_id"
	end

	create_table "employees", :force => true do |t|
		t.integer "provider_id", :null => false
		t.integer "user_id", :null => false
		t.string "clearance", :default => "staff"
		t.boolean "active", :default => true
		t.datetime "created_at", :null => false
		t.datetime "updated_at", :null => false
		t.integer "brand_id"
		t.boolean "retail", :default => true
		t.string "token"
	end

	# create_table "connections", :force => true do |t|
	# 	t.integer "giver_id"
	# 	t.integer "receiver_id"
	# 	t.datetime "created_at", :null => false
	# 	t.datetime "updated_at", :null => false
	# end

	create_table "relays", :force => true do |t|
		t.integer "gift_id"
		t.integer "giver_id"
		t.integer "provider_id"
		t.integer "receiver_id"
		t.string "status"
		t.string "name"
		t.datetime "created_at", :null => false
		t.datetime "updated_at", :null => false
	end
  end
end
