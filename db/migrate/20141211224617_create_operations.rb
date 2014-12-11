class CreateOperations < ActiveRecord::Migration
  def change
	  create_table "operations", force: true do |t|
	    t.integer  "obj_id"
	    t.integer  "user_id"
	    t.integer  "status"
	    t.text     "note"
	    t.text     "response"
	    t.timestamps
	    t.string   "type_of"
	    t.string   "obj_type"
	  end

	  add_index "operations", ["obj_id"], name: "index_operations_on_obj_id", using: :btree
	  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree
  end
end
