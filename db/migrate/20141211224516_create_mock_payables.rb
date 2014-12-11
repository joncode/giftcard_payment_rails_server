class CreateMockPayables < ActiveRecord::Migration
  def change
	  create_table "mock_payables", force: true do |t|
	    t.decimal  "amount"
	    t.integer  "status",            default: 0
	    t.integer  "merchant_id"
	    t.integer  "provider_id"
	    t.string   "name"
	    t.string   "address"
	    t.integer  "user_id"
	    t.string   "last_payment"
	    t.datetime "start_date"
	    t.datetime "end_date"
	    t.text     "json_ary_gift_ids"
	    t.timestamps
	  end

	  add_index "mock_payables", ["merchant_id"], name: "index_mock_payables_on_merchant_id", using: :btree
  end
end
