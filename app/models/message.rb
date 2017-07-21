class Message < ActiveRecord::Base
end



# Message

# 	status [:live, :paused] default: 'live'

# 	rg model Message status message active:boolean company_id:integer company_type

# 		create_table "alert_messages", force: :cascade do |t|
# 			t.integer  "alert_contact_id"
# 			t.integer  "target_id"
# 			t.string   "target_type"
# 			t.string   "status",           default: "unsent"
# 			t.string   "reason"
# 			t.string   "msg"
# 			t.datetime "created_at",                          null: false
# 			t.datetime "updated_at",                          null: false
# 			t.boolean  "active",           default: true
# 		end

