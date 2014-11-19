class CreateBanks < ActiveRecord::Migration
  def change
    create_table :banks do |t|
	    t.integer  :merchant_id
	    t.string   :aba
	    t.string   :account_number
	    t.string   :name
	    t.string   :address
	    t.string   :city,                 limit: 50
	    t.string   :state,                limit: 2
	    t.string   :zip,                  limit: 16
	    t.string   :account_name
	    t.integer  :acct_type
	    t.string   :country,              default: "USA"
	    t.string   :public_account_number
	    t.string   :public_aba
    	t.timestamps
    end
    add_index :banks, ["merchant_id"], name: "index_banks_on_merchant_id", using: :btree
  end
end
