# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20131031205228) do

  create_table "answers", :force => true do |t|
    t.string   "answer"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "approvals", :force => true do |t|
    t.text     "request_str"
    t.string   "unique_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "merchant_id"
    t.integer  "status",      :default => 0
    t.string   "email"
  end

  create_table "attachinary_files", :force => true do |t|
    t.integer  "attachinariable_id"
    t.string   "attachinariable_type"
    t.string   "scope"
    t.string   "public_id"
    t.string   "version"
    t.integer  "width"
    t.integer  "height"
    t.string   "format"
    t.string   "resource_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachinary_files", ["attachinariable_type", "attachinariable_id", "scope"], :name => "by_scoped_parent"

  create_table "banks", :force => true do |t|
    t.integer  "merchant_id"
    t.string   "aba"
    t.string   "account_number"
    t.string   "name"
    t.string   "address"
    t.string   "city",                  :limit => 50
    t.string   "state",                 :limit => 2
    t.string   "zip",                   :limit => 16
    t.string   "account_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "acct_type"
    t.string   "country",                             :default => "USA"
    t.string   "public_account_number"
    t.string   "public_aba"
  end

  create_table "brands", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "phone"
    t.string   "website"
    t.string   "logo"
    t.string   "photo"
    t.string   "portrait"
    t.integer  "user_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "owner_id"
    t.string   "next_view"
    t.boolean  "child",       :default => false
    t.boolean  "active",      :default => true
  end

  create_table "brands_providers", :id => false, :force => true do |t|
    t.integer "provider_id"
    t.integer "brand_id"
  end

  add_index "brands_providers", ["brand_id"], :name => "index_brands_providers_on_brand_id"
  add_index "brands_providers", ["provider_id"], :name => "index_brands_providers_on_provider_id"

  create_table "campaigns", :force => true do |t|
    t.integer  "campaign_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "cards", :force => true do |t|
    t.integer  "user_id"
    t.string   "nickname"
    t.string   "name"
    t.string   "number_digest"
    t.string   "last_four"
    t.string   "month"
    t.string   "year"
    t.string   "csv"
    t.string   "brand"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "cards", ["user_id"], :name => "index_cards_on_user_id"

  create_table "city_providers", :force => true do |t|
    t.string   "city"
    t.text     "providers_array"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "connections", :force => true do |t|
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "connections", ["giver_id"], :name => "index_connections_on_giver_id"
  add_index "connections", ["receiver_id"], :name => "index_connections_on_receiver_id"

  create_table "contacts", :force => true do |t|
    t.integer  "brand_id"
    t.string   "address"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["brand_id"], :name => "index_contacts_on_brand_id"

  create_table "credit_accounts", :force => true do |t|
    t.string   "owner"
    t.integer  "owner_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "employees", :force => true do |t|
    t.integer  "provider_id",                      :null => false
    t.integer  "user_id",                          :null => false
    t.string   "clearance",   :default => "staff"
    t.boolean  "active",      :default => true
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.integer  "brand_id"
    t.boolean  "retail",      :default => true
    t.string   "token"
  end

  add_index "employees", ["provider_id"], :name => "index_employees_on_provider_id"
  add_index "employees", ["token"], :name => "index_employees_on_token"

  create_table "gift_items", :force => true do |t|
    t.integer "gift_id"
    t.integer "menu_id"
    t.string  "price"
    t.integer "quantity"
    t.string  "name"
    t.text    "detail"
  end

  add_index "gift_items", ["gift_id"], :name => "index_gift_items_on_gift_id"

  create_table "gifts", :force => true do |t|
    t.string   "giver_name"
    t.string   "receiver_name"
    t.string   "provider_name"
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.string   "total",          :limit => 20
    t.string   "credit_card",    :limit => 100
    t.integer  "provider_id"
    t.text     "message"
    t.string   "status",                        :default => "unpaid"
    t.datetime "created_at",                                          :null => false
    t.datetime "updated_at",                                          :null => false
    t.string   "receiver_phone"
    t.string   "tax"
    t.string   "tip"
    t.integer  "regift_id"
    t.string   "foursquare_id"
    t.string   "facebook_id"
    t.integer  "anon_id"
    t.integer  "sale_id"
    t.string   "receiver_email"
    t.text     "shoppingCart"
    t.string   "twitter"
    t.string   "service"
    t.string   "order_num"
    t.integer  "cat",                           :default => 0
    t.boolean  "active",                        :default => true
    t.string   "pay_stat"
    t.string   "pay_type"
    t.integer  "pay_id"
    t.datetime "redeemed_at"
    t.string   "server"
    t.integer  "payable_id"
    t.string   "payable_type"
  end

  add_index "gifts", ["giver_id"], :name => "index_gifts_on_giver_id"
  add_index "gifts", ["pay_stat"], :name => "index_gifts_on_pay_stat"
  add_index "gifts", ["provider_id"], :name => "index_gifts_on_provider_id"
  add_index "gifts", ["receiver_id"], :name => "index_gifts_on_receiver_id"
  add_index "gifts", ["status"], :name => "index_gifts_on_status"

  create_table "invites", :force => true do |t|
    t.string   "invite_tkn"
    t.string   "merchant_tkn"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "merchant_id"
    t.string   "clearance",    :default => "staff"
    t.boolean  "active",       :default => true
    t.string   "code"
    t.integer  "user_id"
    t.integer  "rank",         :default => 0
    t.boolean  "general",      :default => false
  end

  add_index "invites", ["invite_tkn"], :name => "index_invites_on_invite_tkn"
  add_index "invites", ["merchant_id"], :name => "index_invites_on_merchant_id"

  create_table "items_menus", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "menu_id"
  end

  create_table "menu_items", :force => true do |t|
    t.string   "name"
    t.integer  "section_id"
    t.integer  "menu_id"
    t.text     "detail"
    t.string   "price"
    t.string   "photo"
    t.integer  "position"
    t.boolean  "active",     :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menu_items", ["menu_id"], :name => "index_menu_items_on_menu_id"
  add_index "menu_items", ["section_id"], :name => "index_menu_items_on_section_id"

  create_table "menu_strings", :force => true do |t|
    t.integer  "version"
    t.integer  "provider_id",   :null => false
    t.string   "full_address"
    t.text     "data",          :null => false
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "sections_json"
    t.text     "menu"
  end

  add_index "menu_strings", ["provider_id"], :name => "index_menu_strings_on_provider_id"

  create_table "merchant_tools", :force => true do |t|
    t.string   "token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "merchant_tools", ["token"], :name => "index_merchant_tools_on_token"

  create_table "merchants", :force => true do |t|
    t.string   "name"
    t.string   "token"
    t.string   "zinger"
    t.text     "description"
    t.boolean  "active",                                                  :default => true
    t.string   "address"
    t.string   "address_2"
    t.string   "city",        :limit => 50
    t.string   "state",       :limit => 2
    t.string   "zip",         :limit => 16
    t.string   "phone",       :limit => 20
    t.string   "email"
    t.string   "website"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "photo"
    t.string   "logo"
    t.decimal  "rate",                      :precision => 8, :scale => 3
    t.decimal  "sales_tax",                 :precision => 8, :scale => 3
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "setup",                                                   :default => "000010"
    t.string   "image"
    t.boolean  "pos",                                                     :default => false
    t.boolean  "tou",                                                     :default => false
    t.integer  "tz",                                                      :default => 0
    t.boolean  "live",                                                    :default => false
    t.boolean  "paused",                                                  :default => true
    t.float    "latitude"
    t.float    "longitude"
  end

  add_index "merchants", ["token"], :name => "index_merchants_on_token"

  create_table "microposts", :force => true do |t|
    t.string   "content",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "mock_payables", :force => true do |t|
    t.decimal  "amount"
    t.integer  "status",            :default => 0
    t.integer  "merchant_id"
    t.integer  "provider_id"
    t.string   "name"
    t.string   "address"
    t.integer  "user_id"
    t.string   "last_payment"
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "json_ary_gift_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mock_payables", ["merchant_id"], :name => "index_mock_payables_on_merchant_id"

  create_table "operations", :force => true do |t|
    t.integer  "obj_id"
    t.integer  "user_id"
    t.integer  "status"
    t.text     "note"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "type_of"
    t.string   "model"
  end

  add_index "operations", ["obj_id"], :name => "index_operations_on_obj_id"
  add_index "operations", ["user_id"], :name => "index_operations_on_user_id"

  create_table "orders", :force => true do |t|
    t.integer  "redeem_id"
    t.integer  "gift_id"
    t.string   "redeem_code"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "server_code"
    t.integer  "server_id"
    t.integer  "provider_id"
    t.integer  "employee_id"
  end

  add_index "orders", ["gift_id"], :name => "index_orders_on_gift_id"

  create_table "payables", :force => true do |t|
    t.decimal  "amount"
    t.integer  "status",            :default => 0
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "payables", ["merchant_id"], :name => "index_payables_on_merchant_id"
  add_index "payables", ["status"], :name => "index_payables_on_status"

  create_table "pn_tokens", :force => true do |t|
    t.integer "user_id"
    t.string  "pn_token"
  end

  add_index "pn_tokens", ["user_id"], :name => "index_pn_tokens_on_user_id"

  create_table "progresses", :force => true do |t|
    t.integer  "merchant_id"
    t.integer  "profile",     :default => 1
    t.integer  "bank",        :default => 0
    t.integer  "photo",       :default => 0
    t.integer  "menu",        :default => 0
    t.integer  "staff",       :default => 0
    t.integer  "approval",    :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "providers", :force => true do |t|
    t.string   "name",                                            :null => false
    t.string   "zinger"
    t.text     "description"
    t.string   "address"
    t.string   "address_2"
    t.string   "city",           :limit => 32
    t.string   "state",          :limit => 2
    t.string   "zip",            :limit => 16
    t.string   "logo"
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
    t.string   "phone"
    t.string   "email"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "photo"
    t.string   "sales_tax"
    t.boolean  "active",                       :default => true
    t.string   "portrait"
    t.string   "box"
    t.float    "latitude"
    t.float    "longitude"
    t.string   "foursquare_id"
    t.decimal  "rate"
    t.boolean  "menu_is_live",                 :default => false
    t.integer  "brand_id"
    t.integer  "building_id"
    t.integer  "sd_location_id"
    t.string   "token"
    t.boolean  "tools",                        :default => false
    t.string   "image"
    t.integer  "merchant_id"
    t.boolean  "live",                         :default => false
    t.boolean  "paused",                       :default => true
  end

  add_index "providers", ["active", "paused", "city"], :name => "index_providers_on_active_and_paused_and_city"
  add_index "providers", ["city"], :name => "index_providers_on_city"
  add_index "providers", ["merchant_id"], :name => "index_providers_on_merchant_id"
  add_index "providers", ["token"], :name => "index_providers_on_token"

  create_table "providers_tags", :id => false, :force => true do |t|
    t.integer "provider_id"
    t.integer "tag_id"
  end

  add_index "providers_tags", ["provider_id"], :name => "index_providers_tags_on_provider_id"
  add_index "providers_tags", ["tag_id"], :name => "index_providers_tags_on_tag_id"

  create_table "questions", :force => true do |t|
    t.string "left"
    t.string "right"
  end

  create_table "redeems", :force => true do |t|
    t.integer  "gift_id"
    t.string   "redeem_code"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "relationships", :force => true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relationships", ["followed_id"], :name => "index_relationships_on_followed_id"
  add_index "relationships", ["follower_id", "followed_id"], :name => "index_relationships_on_follower_id_and_followed_id", :unique => true
  add_index "relationships", ["follower_id"], :name => "index_relationships_on_follower_id"

  create_table "relays", :force => true do |t|
    t.integer  "gift_id"
    t.integer  "giver_id"
    t.integer  "provider_id"
    t.integer  "receiver_id"
    t.string   "status"
    t.string   "name"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "relays", ["gift_id"], :name => "index_relays_on_gift_id"
  add_index "relays", ["provider_id"], :name => "index_relays_on_provider_id"
  add_index "relays", ["receiver_id"], :name => "index_relays_on_receiver_id"

  create_table "sales", :force => true do |t|
    t.integer  "gift_id"
    t.integer  "giver_id"
    t.integer  "card_id"
    t.integer  "provider_id"
    t.string   "transaction_id"
    t.decimal  "revenue"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.text     "resp_json"
    t.text     "req_json"
    t.integer  "resp_code"
    t.string   "reason_text"
    t.integer  "reason_code"
  end

  add_index "sales", ["provider_id"], :name => "index_sales_on_provider_id"

  create_table "sections", :force => true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["menu_id"], :name => "index_sections_on_menu_id"

  create_table "settings", :force => true do |t|
    t.integer  "user_id"
    t.boolean  "email_invoice",               :default => true
    t.boolean  "email_redeem",                :default => true
    t.boolean  "email_invite",                :default => true
    t.boolean  "email_follow_up",             :default => true
    t.boolean  "email_receiver_new",          :default => true
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.string   "confirm_email_token"
    t.string   "confirm_phone_token"
    t.string   "reset_token"
    t.boolean  "confirm_phone_flag",          :default => false
    t.boolean  "confirm_email_flag",          :default => false
    t.datetime "confirm_phone_token_sent_at"
    t.datetime "confirm_email_token_sent_at"
    t.datetime "reset_token_sent_at"
  end

  create_table "tags", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_socials", :force => true do |t|
    t.integer  "user_id"
    t.string   "type_of"
    t.string   "identifier"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "active",     :default => true
    t.boolean  "subscribed", :default => false
  end

  add_index "user_socials", ["active"], :name => "index_user_socials_on_active"

  create_table "users", :force => true do |t|
    t.string   "email",                                                    :null => false
    t.boolean  "admin",                                 :default => false
    t.string   "photo"
    t.string   "password_digest",                                          :null => false
    t.string   "remember_token",                                           :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
    t.string   "address"
    t.string   "address_2"
    t.string   "city",                    :limit => 20
    t.string   "state",                   :limit => 2
    t.string   "zip",                     :limit => 16
    t.string   "credit_number"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "facebook_id"
    t.string   "handle"
    t.string   "server_code"
    t.string   "twitter"
    t.boolean  "active",                                :default => true
    t.string   "persona",                               :default => ""
    t.string   "foursquare_id"
    t.string   "facebook_access_token"
    t.datetime "facebook_expiry"
    t.string   "foursquare_access_token"
    t.string   "sex"
    t.boolean  "is_public"
    t.boolean  "facebook_auth_checkin"
    t.string   "iphone_photo"
    t.string   "fb_photo"
    t.string   "use_photo"
    t.string   "secure_image"
    t.datetime "reset_token_sent_at"
    t.string   "reset_token"
    t.date     "birthday"
    t.string   "origin"
    t.string   "confirm",                               :default => "00"
    t.boolean  "perm_deactive",                         :default => false
  end

  add_index "users", ["active", "perm_deactive"], :name => "index_users_on_active_and_perm_deactive"
  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
