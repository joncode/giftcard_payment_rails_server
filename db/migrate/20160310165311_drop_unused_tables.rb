class DropUnusedTables < ActiveRecord::Migration
	def up
		drop_table :daily_stats
		drop_table :data_transfers
		drop_table :brands_providers
		drop_table :gift_promo_mocks
		drop_table :gift_promo_socials
	end

	def down
		create_table "gift_promo_mocks", force: :cascade do |t|
			t.string   "type_of",       limit: 255
			t.string   "receiver_name", limit: 255
			t.datetime "expires_at"
			t.text     "message"
			t.text     "shoppingCart"
			t.text     "detail"
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "gift_promo_socials", force: :cascade do |t|
			t.integer  "gift_promo_mock_id"
			t.string   "network",            limit: 255
			t.string   "network_id",         limit: 255
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "brands_providers", id: false, force: :cascade do |t|
			t.integer "provider_id"
			t.integer "brand_id"
			t.integer "merchant_id"
		end

		create_table "daily_stats", force: :cascade do |t|
			t.string   "dash_day_old",   limit: 255
			t.string   "dash_week_old",  limit: 255
			t.string   "dash_month_old", limit: 255
			t.string   "dash_total",     limit: 255
			t.datetime "created_at"
			t.datetime "updated_at"
		end

		create_table "data_transfers", force: :cascade do |t|
			t.json     "model_names"
			t.json     "data"
			t.datetime "created_at"
			t.datetime "updated_at"
		end
	end
end
