class DropObsoleteTables < ActiveRecord::Migration
  def up
  	drop_table :locations
  	drop_table :menus
  	drop_table :items
  end

  def down
	create_table "locations", :force => true do |t|
	    t.float    "latitude"
	    t.float    "longitude"
	    t.integer  "provider_id"
	    t.integer  "user_id"
	    t.datetime "created_at",  :null => false
	    t.datetime "updated_at",  :null => false
	    t.string   "vendor_id"
	    t.string   "vendor_type"
	    t.string   "name"
	    t.string   "street"
	    t.string   "city"
	    t.string   "state"
	    t.string   "country"
	    t.string   "zip"
	    t.string   "checkin_id"
	    t.string   "message"
	  end

	create_table "menus", :force => true do |t|
	    t.integer  "provider_id",                                 :null => false
	    t.integer  "item_id",                                     :null => false
	    t.string   "price",       :limit => 20
	    t.integer  "position",    :limit => 8
	    t.datetime "created_at",                                  :null => false
	    t.datetime "updated_at",                                  :null => false
	    t.string   "item_name"
	    t.string   "photo"
	    t.string   "description"
	    t.string   "section"
	    t.boolean  "active",                    :default => true
	  end

	create_table "items", :force => true do |t|
	    t.string  "item_name",   :limit => 50, :null => false
	    t.string  "detail"
	    t.text    "description"
	    t.integer "category",                  :null => false
	    t.string  "proof"
	    t.string  "type_of"
	    t.string  "photo"
	    t.integer "brand_id"
	    t.integer "supplier_id"
	end
  end
end
