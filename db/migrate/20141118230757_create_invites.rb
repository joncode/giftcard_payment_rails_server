class CreateInvites < ActiveRecord::Migration
  def change
    create_table :invites do |t|
	    t.string   :invite_tkn
	    t.string   :merchant_tkn
	    t.string   :email
	    t.integer  :user_id
	    t.integer  :merchant_id
	    t.boolean  :active,       default: true
	    t.string   :code
	    t.integer  :rank,         default: 0
	    t.boolean  :general,      default: false
	    t.timestamps
    end
	add_index :invites, ["invite_tkn"], name: "index_invites_on_invite_tkn", using: :btree
	add_index :invites, ["merchant_id"], name: "index_invites_on_merchant_id", using: :btree
	add_index :invites, ["user_id"], name: "index_invites_on_user_id", using: :btree
  end
end
