class CreatePayables < ActiveRecord::Migration
  def change
	create_table "payables", force: true do |t|
		t.decimal  "amount"
		t.integer  "status",              default: 0
		t.integer  "merchant_id"
		t.integer  "provider_id"
		t.string   "name"
		t.string   "address"
		t.integer  "user_id"
		t.string   "last_payment"
		t.datetime "start_date"
		t.string   "payment_date"
		t.datetime "end_date"
		t.text     "json_ary_gift_ids"
		t.timestamps
		t.string   "confirmation_number"
	end

	add_index "payables", ["merchant_id", "payment_date"], name: "index_payables_on_merchant_id_and_payment_date", using: :btree
	add_index "payables", ["merchant_id"], name: "index_payables_on_merchant_id", using: :btree
	add_index "payables", ["status"], name: "index_payables_on_status", using: :btree
  end
end
