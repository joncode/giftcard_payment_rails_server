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

<<<<<<< HEAD
ActiveRecord::Schema.define(:version => 20130920203446) do
=======
ActiveRecord::Schema.define(:version => 20130924014353) do
>>>>>>> m

  create_table "admin_tokens", :force => true do |t|
    t.string   "token"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "admin_tokens", ["token"], :name => "index_admin_tokens_on_token"

  create_table "answers", :force => true do |t|
    t.string   "answer"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
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

  create_table "connections", :force => true do |t|
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "connections", ["giver_id"], :name => "index_connections_on_giver_id"
  add_index "connections", ["receiver_id"], :name => "index_connections_on_receiver_id"

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
  end

  add_index "gifts", ["giver_id"], :name => "index_gifts_on_giver_id"
  add_index "gifts", ["provider_id"], :name => "index_gifts_on_provider_id"
  add_index "gifts", ["receiver_id"], :name => "index_gifts_on_receiver_id"

  create_table "items", :force => true do |t|
    t.string  "item_name",   :limit => 50, :null => false
    t.string  "detail"
    t.text    "description"
    t.integer "category",    :limit => 20, :null => false
    t.string  "proof"
    t.string  "type_of"
    t.string  "photo"
    t.integer "brand_id"
    t.integer "supplier_id"
  end

  create_table "items_menus", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "menu_id"
  end

  create_table "locations", :force => true do |t|
    t.float    "latitude"
    t.float    "longitude"
    t.integer  "provider_id"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "vendor_id"
    t.string   "vendor_type"
    t.string   "name"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "zip"
    t.string   "checkin_id"
    t.string   "message"
  end

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

  create_table "menus", :force => true do |t|
    t.integer  "provider_id"
    t.integer  "item_id"
    t.string   "price",       :limit => 20
    t.integer  "position",    :limit => 8
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "item_name"
    t.string   "photo"
    t.string   "description"
    t.string   "section"
    t.boolean  "active",                    :default => true
  end

  add_index "menus", ["provider_id"], :name => "index_menus_on_provider_id"

  create_table "microposts", :force => true do |t|
    t.string   "content",    :null => false
    t.integer  "user_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

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

  create_table "pn_tokens", :force => true do |t|
    t.integer "user_id"
    t.string  "pn_token"
  end

  add_index "pn_tokens", ["user_id"], :name => "index_pn_tokens_on_user_id"

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
    t.integer  "sd_location_id"
    t.integer  "brand_id"
    t.integer  "building_id"
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
    t.datetime "created_at",                   :null => false
    t.datetime "updated_at",                   :null => false
    t.boolean  "active",     :default => true
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                                    :null => false
    t.boolean  "admin",                                 :default => false
    t.string   "photo"
    t.string   "password_digest"
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
  end

  add_index "users", ["remember_token"], :name => "index_users_on_remember_token"

end
