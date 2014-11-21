class CreateMenus < ActiveRecord::Migration
  def change
    create_table :menus do |t|
	    t.string   :merchant_token
	    t.text     :json
	    t.integer  :merchant_id
	    t.integer  :type_of
	    t.boolean  :edited
	    t.timestamps
    end
	add_index :menus, ["merchant_id"], name: "index_menus_on_merchant_id", using: :btree
	add_index :menus, ["merchant_token"], name: "index_menus_on_merchant_token", using: :btree
  end
end
