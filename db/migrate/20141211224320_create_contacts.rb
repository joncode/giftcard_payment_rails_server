class CreateContacts < ActiveRecord::Migration
  def change
	create_table "contacts", force: true do |t|
		t.integer  "brand_id"
		t.string   "address"
		t.string   "city"
		t.string   "state"
		t.string   "zip"
		t.string   "name"
		t.string   "email"
		t.string   "phone"
		t.timestamps
	end
	add_index "contacts", ["brand_id"], name: "index_contacts_on_brand_id", using: :btree
  end
end
