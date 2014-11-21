class CreateMtUsers < ActiveRecord::Migration
  def change
    create_table :mt_users do |t|
	    t.string   :first_name
	    t.string   :last_name
	    t.string   :email
	    t.string   :phone
	    t.string   :sex
	    t.date     :birthday
	    t.string   :password_digest
	    t.string   :remember_token,                                 null: false
	    t.boolean  :admin,                          default: false
	    t.integer  :confirm,                        default: 0
	    t.datetime :reset_token_sent_at
	    t.string   :reset_token
	    t.boolean  :active,                         default: true
	    t.integer  :db_user_id
	    t.string   :address
	    t.string   :city
	    t.string   :state,               limit: 2
	    t.string   :zip,                 limit: 16
	    t.string   :facebook_id
	    t.string   :twitter
	    t.string   :photo
	    t.string   :min_photo
	    t.timestamps
    end
	add_index :mt_users, ["db_user_id"], name: "index_mt_users_on_db_user_id", using: :btree
	add_index :mt_users, ["email"], name: "index_mt_users_on_email", using: :btree
	add_index :mt_users, ["remember_token"], name: "index_mt_users_on_remember_token", using: :btree
  end
end
