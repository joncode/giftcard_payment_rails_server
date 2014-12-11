class CreateAtUsers < ActiveRecord::Migration
  def change
	  create_table "at_users", force: true do |t|
	    t.string   "first_name"
	    t.string   "last_name"
	    t.string   "email"
	    t.string   "phone"
	    t.string   "sex"
	    t.date     "birthday"
	    t.string   "password_digest"
	    t.string   "remember_token",                                 null: false
	    t.boolean  "admin",                          default: false
	    t.string   "code"
	    t.integer  "confirm",                        default: 0
	    t.datetime "reset_token_sent_at"
	    t.string   "reset_token"
	    t.boolean  "active",                         default: true
	    t.integer  "db_user_id"
	    t.string   "address"
	    t.string   "city"
	    t.string   "state",               limit: 2
	    t.string   "zip",                 limit: 16
	    t.string   "photo"
	    t.string   "min_photo"
	    t.timestamps
	    t.datetime "last_login"
	    t.integer  "time_zone",                      default: 0
	    t.boolean  "acct",                           default: false
	  end

	  add_index "at_users", ["remember_token"], name: "index_at_users_on_remember_token", using: :btree
  end
end
