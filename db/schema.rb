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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140724233226) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "answers", force: true do |t|
    t.string   "answer"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "app_contacts", force: true do |t|
    t.string   "network"
    t.string   "network_id"
    t.string   "name"
    t.date     "birthday"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "boomerangs", force: true do |t|
  end

  create_table "brands", force: true do |t|
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
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "owner_id"
    t.string   "next_view"
    t.boolean  "child",       default: false
    t.boolean  "active",      default: true
  end

  add_index "brands", ["active"], name: "index_brands_on_active", using: :btree

  create_table "brands_providers", id: false, force: true do |t|
    t.integer "provider_id"
    t.integer "brand_id"
  end

  add_index "brands_providers", ["brand_id"], name: "index_brands_providers_on_brand_id", using: :btree
  add_index "brands_providers", ["provider_id"], name: "index_brands_providers_on_provider_id", using: :btree

  create_table "bulk_contacts", force: true do |t|
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bulk_emails", force: true do |t|
    t.text     "data"
    t.boolean  "processed",   default: false
    t.integer  "proto_id"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "campaign_items", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "provider_id"
    t.integer  "giver_id"
    t.string   "giver_name"
    t.integer  "budget"
    t.integer  "reserve"
    t.text     "message"
    t.text     "shoppingCart"
    t.string   "value"
    t.string   "cost"
    t.date     "expires_at"
    t.integer  "expires_in"
    t.string   "textword"
    t.boolean  "contract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "detail"
  end

  create_table "campaigns", force: true do |t|
    t.string   "type_of"
    t.string   "status"
    t.string   "name"
    t.text     "notes"
    t.date     "live_date"
    t.date     "close_date"
    t.date     "expire_date"
    t.integer  "purchaser_id"
    t.string   "purchaser_type"
    t.string   "giver_name"
    t.string   "photo"
    t.integer  "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_path"
  end

  create_table "cards", force: true do |t|
    t.integer  "user_id"
    t.string   "nickname"
    t.string   "name"
    t.string   "number_digest"
    t.string   "last_four"
    t.string   "month"
    t.string   "year"
    t.string   "csv"
    t.string   "brand"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "credit_accounts", force: true do |t|
    t.string   "owner"
    t.integer  "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "debts", force: true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.decimal  "amount",     precision: 8, scale: 2
    t.decimal  "total",      precision: 8, scale: 2
    t.string   "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dittos", force: true do |t|
    t.text     "response_json"
    t.integer  "status"
    t.integer  "cat"
    t.integer  "notable_id"
    t.string   "notable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dittos", ["notable_id", "notable_type"], name: "index_dittos_on_notable_id_and_notable_type", using: :btree
  add_index "dittos", ["status"], name: "index_dittos_on_status", using: :btree

  create_table "friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "app_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["app_contact_id"], name: "index_friendships_on_app_contact_id", using: :btree
  add_index "friendships", ["user_id", "app_contact_id"], name: "index_friendships_on_user_id_and_app_contact_id", unique: true, using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "gift_items", force: true do |t|
    t.integer "gift_id"
    t.integer "menu_id"
    t.string  "price"
    t.integer "quantity"
    t.string  "name"
    t.text    "detail"
  end

  add_index "gift_items", ["gift_id"], name: "index_gift_items_on_gift_id", using: :btree

  create_table "gifts", force: true do |t|
    t.string   "giver_name"
    t.string   "receiver_name"
    t.string   "provider_name"
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.string   "total",          limit: 20
    t.string   "credit_card",    limit: 100
    t.integer  "provider_id"
    t.text     "message"
    t.string   "status",                     default: "unpaid"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "receiver_phone"
    t.string   "facebook_id"
    t.integer  "anon_id"
    t.string   "receiver_email"
    t.text     "shoppingCart"
    t.string   "twitter"
    t.string   "service"
    t.string   "order_num"
    t.integer  "cat",                        default: 0
    t.boolean  "active",                     default: true
    t.string   "pay_stat"
    t.datetime "redeemed_at"
    t.string   "server"
    t.integer  "payable_id"
    t.string   "payable_type"
    t.string   "giver_type"
    t.string   "value"
    t.datetime "expires_at"
    t.integer  "refund_id"
    t.string   "refund_type"
    t.string   "cost"
    t.text     "detail"
  end

  add_index "gifts", ["active"], name: "index_gifts_on_active", using: :btree
  add_index "gifts", ["giver_id"], name: "index_gifts_on_giver_id", using: :btree
  add_index "gifts", ["pay_stat"], name: "index_gifts_on_pay_stat", using: :btree
  add_index "gifts", ["provider_id"], name: "index_gifts_on_provider_id", using: :btree
  add_index "gifts", ["receiver_id"], name: "index_gifts_on_receiver_id", using: :btree
  add_index "gifts", ["status"], name: "index_gifts_on_status", using: :btree

  create_table "menu_strings", force: true do |t|
    t.integer  "version"
    t.integer  "provider_id",   null: false
    t.string   "full_address"
    t.text     "data",          null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "sections_json"
    t.text     "menu"
  end

  add_index "menu_strings", ["provider_id"], name: "index_menu_strings_on_provider_id", using: :btree

  create_table "oauths", force: true do |t|
    t.integer  "gift_id"
    t.string   "token"
    t.string   "secret"
    t.string   "network"
    t.string   "network_id"
    t.string   "handle"
    t.string   "photo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "orders", force: true do |t|
    t.integer  "redeem_id"
    t.integer  "gift_id"
    t.string   "redeem_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "server_code"
    t.integer  "server_id"
    t.integer  "provider_id"
    t.integer  "employee_id"
    t.integer  "pos_merchant_id"
    t.string   "ticket_value"
    t.string   "ticket_item_ids"
  end

  add_index "orders", ["gift_id"], name: "index_orders_on_gift_id", using: :btree

  create_table "pn_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "pn_token"
    t.string   "platform",   default: "ios"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pn_tokens", ["user_id"], name: "index_pn_tokens_on_user_id", using: :btree

  create_table "proto_joins", force: true do |t|
    t.integer  "proto_id"
    t.integer  "receivable_id"
    t.string   "receivable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gift_id"
    t.string   "rec_name"
  end

  add_index "proto_joins", ["gift_id"], name: "index_proto_joins_on_gift_id", using: :btree
  add_index "proto_joins", ["receivable_id", "proto_id"], name: "index_proto_joins_on_receivable_id_and_proto_id", using: :btree
  add_index "proto_joins", ["receivable_id", "receivable_type"], name: "index_proto_joins_on_receivable_id_and_receivable_type", using: :btree

  create_table "protos", force: true do |t|
    t.text     "message"
    t.text     "detail"
    t.text     "shoppingCart"
    t.string   "value"
    t.string   "cost"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "giver_id"
    t.string   "giver_type"
    t.string   "giver_name"
    t.integer  "provider_id"
    t.string   "provider_name"
    t.integer  "cat"
    t.integer  "contacts",      default: 0
    t.integer  "processed",     default: 0
  end

  create_table "providers", force: true do |t|
    t.string   "name",                                       null: false
    t.string   "zinger"
    t.text     "description"
    t.string   "address"
    t.string   "address_2"
    t.string   "city",            limit: 32
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 16
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "phone"
    t.string   "email"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "website"
    t.string   "sales_tax"
    t.boolean  "active",                     default: true
    t.float    "latitude"
    t.float    "longitude"
    t.string   "foursquare_id"
    t.decimal  "rate"
    t.boolean  "menu_is_live",               default: false
    t.integer  "brand_id"
    t.integer  "building_id"
    t.integer  "sd_location_id"
    t.string   "token"
    t.boolean  "tools",                      default: false
    t.string   "image"
    t.integer  "merchant_id"
    t.boolean  "live",                       default: false
    t.boolean  "paused",                     default: true
    t.integer  "pos_merchant_id"
    t.integer  "region_id"
  end

  add_index "providers", ["active", "paused", "city"], name: "index_providers_on_active_and_paused_and_city", using: :btree
  add_index "providers", ["city"], name: "index_providers_on_city", using: :btree
  add_index "providers", ["merchant_id"], name: "index_providers_on_merchant_id", using: :btree
  add_index "providers", ["pos_merchant_id"], name: "index_providers_on_pos_merchant_id", using: :btree
  add_index "providers", ["region_id"], name: "index_providers_on_region_id", using: :btree
  add_index "providers", ["token"], name: "index_providers_on_token", using: :btree

  create_table "providers_socials", id: false, force: true do |t|
    t.integer "provider_id", null: false
    t.integer "social_id",   null: false
  end

  add_index "providers_socials", ["provider_id", "social_id"], name: "index_providers_socials_on_provider_id_and_social_id", unique: true, using: :btree
  add_index "providers_socials", ["provider_id"], name: "index_providers_socials_on_provider_id", using: :btree

  create_table "providers_tags", id: false, force: true do |t|
    t.integer "provider_id"
    t.integer "tag_id"
  end

  add_index "providers_tags", ["provider_id"], name: "index_providers_tags_on_provider_id", using: :btree
  add_index "providers_tags", ["tag_id"], name: "index_providers_tags_on_tag_id", using: :btree

  create_table "questions", force: true do |t|
    t.string "left"
    t.string "right"
  end

  create_table "redeems", force: true do |t|
    t.integer  "gift_id"
    t.string   "redeem_code"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "pos_merchant_id"
  end

  add_index "redeems", ["gift_id"], name: "index_redeems_on_gift_id", using: :btree

  create_table "relationships", force: true do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "pushed",      default: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "sales", force: true do |t|
    t.integer  "gift_id"
    t.integer  "giver_id"
    t.integer  "card_id"
    t.integer  "provider_id"
    t.string   "transaction_id"
    t.decimal  "revenue"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.text     "resp_json"
    t.text     "req_json"
    t.integer  "resp_code"
    t.string   "reason_text"
    t.integer  "reason_code"
  end

  add_index "sales", ["provider_id"], name: "index_sales_on_provider_id", using: :btree

  create_table "settings", force: true do |t|
    t.integer  "user_id"
    t.boolean  "email_invoice",                default: true
    t.boolean  "email_redeem",                 default: true
    t.boolean  "email_invite",                 default: true
    t.boolean  "email_follow_up",              default: true
    t.boolean  "email_receiver_new",           default: true
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
    t.string   "confirm_email_token"
    t.string   "confirm_phone_token"
    t.string   "reset_token"
    t.boolean  "confirm_phone_flag",           default: false
    t.boolean  "confirm_email_flag",           default: false
    t.datetime "confirm_phone_token_sent_at"
    t.datetime "confirm_email_token_sent_at"
    t.datetime "reset_token_sent_at"
    t.boolean  "email_reminder_gift_receiver", default: true
    t.boolean  "email_reminder_gift_giver",    default: true
  end

  create_table "sms_contacts", force: true do |t|
    t.integer  "gift_id"
    t.datetime "subscribed_date"
    t.string   "phone"
    t.integer  "service_id"
    t.string   "service"
    t.string   "textword"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sms_contacts", ["gift_id"], name: "index_sms_contacts_on_gift_id", using: :btree
  add_index "sms_contacts", ["subscribed_date"], name: "index_sms_contacts_on_subscribed_date", using: :btree

  create_table "socials", force: true do |t|
    t.string   "network_id"
    t.string   "network"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "socials", ["network_id", "network"], name: "index_socials_on_network_id_and_network", using: :btree

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_socials", force: true do |t|
    t.integer  "user_id"
    t.string   "type_of"
    t.string   "identifier"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "active",     default: true
    t.boolean  "subscribed", default: false
    t.string   "name"
    t.date     "birthday"
    t.string   "handle"
  end

  add_index "user_socials", ["active"], name: "index_user_socials_on_active", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.boolean  "admin",                              default: false
    t.string   "password_digest",                                    null: false
    t.string   "remember_token",                                     null: false
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
    t.string   "address"
    t.string   "address_2"
    t.string   "city",                    limit: 20
    t.string   "state",                   limit: 2
    t.string   "zip",                     limit: 16
    t.string   "credit_number"
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "facebook_id"
    t.string   "handle"
    t.string   "server_code"
    t.string   "twitter"
    t.boolean  "active",                             default: true
    t.string   "persona",                            default: ""
    t.string   "foursquare_id"
    t.string   "facebook_access_token"
    t.datetime "facebook_expiry"
    t.string   "foursquare_access_token"
    t.string   "sex"
    t.boolean  "is_public"
    t.boolean  "facebook_auth_checkin"
    t.string   "iphone_photo"
    t.datetime "reset_token_sent_at"
    t.string   "reset_token"
    t.date     "birthday"
    t.string   "origin"
    t.string   "confirm",                            default: "00"
    t.boolean  "perm_deactive",                      default: false
  end

  add_index "users", ["active", "perm_deactive"], name: "index_users_on_active_and_perm_deactive", using: :btree
  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
