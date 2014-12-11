class CreateUsersAnother < ActiveRecord::Migration
  def change
	  create_table "users", force: true do |t|
	    t.string   "email"
	    t.string   "password_digest",                                null: false
	    t.string   "remember_token",                                 null: false
	    t.datetime "created_at",                                     null: false
	    t.datetime "updated_at",                                     null: false
	    t.string   "address"
	    t.string   "address_2"
	    t.string   "city",                limit: 20
	    t.string   "state",               limit: 2
	    t.string   "zip",                 limit: 16
	    t.string   "phone"
	    t.string   "first_name"
	    t.string   "last_name"
	    t.string   "facebook_id"
	    t.string   "handle"
	    t.string   "twitter"
	    t.boolean  "active",                         default: true
	    t.string   "persona",                        default: ""
	    t.string   "sex"
	    t.boolean  "is_public"
	    t.string   "iphone_photo"
	    t.datetime "reset_token_sent_at"
	    t.string   "reset_token"
	    t.date     "birthday"
	    t.string   "origin"
	    t.string   "confirm",                        default: "00"
	    t.boolean  "perm_deactive",                  default: false
	    t.string   "cim_profile"
	    t.tsvector "ftmeta"
	  end

	  add_index "users", ["active", "perm_deactive"], name: "index_users_on_active_and_perm_deactive", using: :btree
	  add_index "users", ["ftmeta"], name: "users_ftsmeta_idx", using: :gin
	  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree
  end
end
