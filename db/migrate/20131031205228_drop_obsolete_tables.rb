class DropObsoleteTables < ActiveRecord::Migration
  def up
  	drop_table :locations
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
  end
end
