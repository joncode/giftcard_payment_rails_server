class CreateProgresses < ActiveRecord::Migration
  def change
    create_table :progresses do |t|
	    t.integer  :merchant_id
	    t.integer  :profile,     default: 1
	    t.integer  :bank,        default: 0
	    t.integer  :photo,       default: 0
	    t.integer  :menu,        default: 0
	    t.integer  :staff,       default: 0
	    t.integer  :approval,    default: 0
	    t.timestamps
    end
    add_index :progresses, ["merchant_id"], name: "index_progresses_on_merchant_id", using: :btree
  end
end
