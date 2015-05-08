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

ActiveRecord::Schema.define(version: 20150508233726) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id", using: :btree
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace", using: :btree
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id", using: :btree

  create_table "affiliates", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "address"
    t.string   "state"
    t.string   "city"
    t.string   "zip"
    t.string   "url_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_merchants",    default: 0
    t.integer  "payout_merchants",   default: 0
    t.integer  "total_users",        default: 0
    t.integer  "payout_users",       default: 0
    t.integer  "payout_links",       default: 0
    t.integer  "value_links",        default: 0
    t.integer  "value_users",        default: 0
    t.integer  "value_merchants",    default: 0
    t.integer  "purchase_links",     default: 0
    t.integer  "purchase_users",     default: 0
    t.integer  "purchase_merchants", default: 0
    t.string   "company"
    t.string   "website_url"
  end

  add_index "affiliates", ["url_name"], name: "index_affiliates_on_url_name", using: :btree

  create_table "affiliates_gifts", id: false, force: true do |t|
    t.integer "affiliate_id"
    t.integer "gift_id"
    t.integer "landing_page_id"
  end

  add_index "affiliates_gifts", ["affiliate_id"], name: "index_affiliates_gifts_on_affiliate_id", using: :btree
  add_index "affiliates_gifts", ["gift_id"], name: "index_affiliates_gifts_on_gift_id", using: :btree

  create_table "affiliations", force: true do |t|
    t.integer  "affiliate_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "name"
    t.string   "address"
    t.integer  "payout",       default: 0
    t.integer  "status",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliations", ["affiliate_id", "target_type"], name: "index_affiliations_on_affiliate_id_and_target_type", using: :btree
  add_index "affiliations", ["affiliate_id"], name: "index_affiliations_on_affiliate_id", using: :btree

  create_table "answers", force: true do |t|
    t.string   "answer"
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "app_contacts", force: true do |t|
    t.string   "network"
    t.string   "network_id"
    t.string   "name"
    t.date     "birthday"
    t.string   "handle"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "at_users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "sex"
    t.date     "birthday"
    t.string   "password_digest"
    t.string   "remember_token",                                    null: false
    t.boolean  "admin",                             default: false
    t.string   "code"
    t.integer  "confirm",                           default: 0
    t.datetime "reset_token_sent_at"
    t.string   "reset_token"
    t.boolean  "active",                            default: true
    t.integer  "db_user_id"
    t.string   "address"
    t.string   "city"
    t.string   "state",                  limit: 2
    t.string   "zip",                    limit: 16
    t.string   "photo"
    t.string   "min_photo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_login"
    t.integer  "time_zone",                         default: 0
    t.boolean  "acct",                              default: false
    t.string   "encrypted_password",                default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "at_users", ["email"], name: "index_at_users_on_email", unique: true, using: :btree
  add_index "at_users", ["remember_token"], name: "index_at_users_on_remember_token", using: :btree
  add_index "at_users", ["reset_password_token"], name: "index_at_users_on_reset_password_token", unique: true, using: :btree

  create_table "at_users_socials", force: true do |t|
    t.integer  "at_user_id"
    t.integer  "social_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachinary_files", force: true do |t|
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

  add_index "attachinary_files", ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree

  create_table "banks", force: true do |t|
    t.integer  "merchant_id"
    t.string   "aba"
    t.string   "account_number"
    t.string   "name"
    t.string   "address"
    t.string   "city",                  limit: 50
    t.string   "state",                 limit: 2
    t.string   "zip",                   limit: 16
    t.string   "account_name"
    t.integer  "acct_type"
    t.string   "country",                          default: "USA"
    t.string   "public_account_number"
    t.string   "public_aba"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "banks", ["merchant_id"], name: "index_banks_on_merchant_id", using: :btree

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
    t.integer  "at_user_id"
  end

  add_index "bulk_emails", ["at_user_id"], name: "index_bulk_emails_on_at_user_id", using: :btree
  add_index "bulk_emails", ["proto_id"], name: "index_bulk_emails_on_proto_id", using: :btree

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

  add_index "campaign_items", ["campaign_id"], name: "index_campaign_items_on_campaign_id", using: :btree
  add_index "campaign_items", ["textword"], name: "index_campaign_items_on_textword", using: :btree

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

  add_index "campaigns", ["close_date"], name: "index_campaigns_on_close_date", using: :btree

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
    t.string   "cim_token"
  end

  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "contacts", force: true do |t|
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

  add_index "contacts", ["brand_id"], name: "index_contacts_on_brand_id", using: :btree

  create_table "credit_accounts", force: true do |t|
    t.string   "owner"
    t.integer  "owner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "daily_stats", force: true do |t|
    t.string   "dash_day_old"
    t.string   "dash_week_old"
    t.string   "dash_month_old"
    t.string   "dash_total"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_transfers", force: true do |t|
    t.json     "model_names"
    t.json     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "gift_analytics", force: true do |t|
    t.date     "date_on"
    t.integer  "created",    default: 0
    t.integer  "admin",      default: 0
    t.integer  "merchant",   default: 0
    t.integer  "campaign",   default: 0
    t.integer  "purchase",   default: 0
    t.integer  "boomerang",  default: 0
    t.integer  "other",      default: 0
    t.integer  "regifted",   default: 0
    t.integer  "notified",   default: 0
    t.integer  "redeemed",   default: 0
    t.integer  "expired",    default: 0
    t.integer  "cregifted",  default: 0
    t.integer  "completed",  default: 0
    t.integer  "velocity",   default: 0
    t.integer  "revenue",    default: 0
    t.integer  "profit",     default: 0
    t.integer  "retail_v",   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "gift_analytics", ["date_on"], name: "index_gift_analytics_on_date_on", using: :btree

  create_table "gift_items", force: true do |t|
    t.integer "gift_id"
    t.integer "menu_id"
    t.string  "price"
    t.integer "quantity"
    t.string  "name"
    t.text    "detail"
  end

  add_index "gift_items", ["gift_id"], name: "index_gift_items_on_gift_id", using: :btree

  create_table "gift_promo_mocks", force: true do |t|
    t.string   "type_of"
    t.string   "receiver_name"
    t.datetime "expires_at"
    t.text     "message"
    t.text     "shoppingCart"
    t.text     "detail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gift_promo_socials", force: true do |t|
    t.integer  "gift_promo_mock_id"
    t.string   "network"
    t.string   "network_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gifts", force: true do |t|
    t.string   "giver_name"
    t.string   "receiver_name"
    t.string   "provider_name"
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.string   "credit_card",    limit: 100
    t.integer  "provider_id"
    t.text     "message"
    t.string   "status",                     default: "unpaid"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "receiver_phone"
    t.string   "facebook_id"
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
    t.tsvector "ftmeta"
    t.datetime "notified_at"
    t.datetime "new_token_at"
    t.integer  "token"
    t.integer  "balance"
    t.string   "origin"
  end

  add_index "gifts", ["active", "pay_stat"], name: "index_gifts_on_active_and_pay_stat", using: :btree
  add_index "gifts", ["active"], name: "index_gifts_on_active", using: :btree
  add_index "gifts", ["cat"], name: "index_gifts_on_cat", using: :btree
  add_index "gifts", ["ftmeta"], name: "gifts_ftsmeta_idx", using: :gin
  add_index "gifts", ["giver_id"], name: "index_gifts_on_giver_id", using: :btree
  add_index "gifts", ["pay_stat"], name: "index_gifts_on_pay_stat", using: :btree
  add_index "gifts", ["payable_id", "payable_type"], name: "index_gifts_on_payable_id_and_payable_type", using: :btree
  add_index "gifts", ["provider_id", "created_at"], name: "index_gifts_on_provider_id_and_created_at", using: :btree
  add_index "gifts", ["provider_id", "status"], name: "index_gifts_on_provider_id_and_status", using: :btree
  add_index "gifts", ["provider_id"], name: "index_gifts_on_provider_id", using: :btree
  add_index "gifts", ["receiver_id"], name: "index_gifts_on_receiver_id", using: :btree
  add_index "gifts", ["status"], name: "index_gifts_on_status", using: :btree

  create_table "invites", force: true do |t|
    t.string   "invite_tkn"
    t.string   "merchant_tkn"
    t.string   "email"
    t.integer  "user_id"
    t.integer  "merchant_id"
    t.boolean  "active",                   default: true
    t.string   "code"
    t.integer  "rank",                     default: 0
    t.boolean  "general",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "clearance",    limit: 225
  end

  add_index "invites", ["invite_tkn"], name: "index_invites_on_invite_tkn", using: :btree
  add_index "invites", ["merchant_id"], name: "index_invites_on_merchant_id", using: :btree
  add_index "invites", ["user_id"], name: "index_invites_on_user_id", using: :btree

  create_table "landing_pages", force: true do |t|
    t.integer  "campaign_id"
    t.integer  "affiliate_id"
    t.string   "title"
    t.string   "banner_photo_url"
    t.integer  "example_item_id"
    t.json     "page_json"
    t.string   "sponsor_photo_url"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clicks",            default: 0
    t.integer  "users",             default: 0
    t.integer  "gifts",             default: 0
  end

  add_index "landing_pages", ["link"], name: "index_landing_pages_on_link", using: :btree

  create_table "menu_items", force: true do |t|
    t.string   "name"
    t.integer  "section_id"
    t.integer  "menu_id"
    t.text     "detail"
    t.string   "price"
    t.string   "photo"
    t.integer  "position"
    t.boolean  "active",      default: true
    t.string   "price_promo"
    t.boolean  "standard",    default: false
    t.boolean  "promo",       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menu_items", ["menu_id"], name: "index_menu_items_on_menu_id", using: :btree
  add_index "menu_items", ["section_id"], name: "index_menu_items_on_section_id", using: :btree

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

  create_table "menus", force: true do |t|
    t.string   "merchant_token"
    t.text     "json"
    t.integer  "merchant_id"
    t.integer  "type_of"
    t.boolean  "edited"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "menus", ["merchant_id"], name: "index_menus_on_merchant_id", using: :btree
  add_index "menus", ["merchant_token"], name: "index_menus_on_merchant_token", using: :btree

  create_table "merchant_signups", force: true do |t|
    t.string   "name"
    t.string   "position"
    t.string   "email"
    t.string   "phone"
    t.string   "website"
    t.string   "venue_name"
    t.string   "venue_url"
    t.string   "point_of_sale_system"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active"
    t.string   "address"
  end

  add_index "merchant_signups", ["active"], name: "index_merchant_signups_on_active", using: :btree

  create_table "merchants", force: true do |t|
    t.string   "name"
    t.string   "token"
    t.string   "zinger"
    t.text     "description"
    t.boolean  "active",                                              default: true
    t.string   "address"
    t.string   "address_2"
    t.string   "city",             limit: 50
    t.string   "state",            limit: 2
    t.string   "zip",              limit: 16
    t.string   "phone",            limit: 20
    t.string   "email"
    t.string   "website"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "photo"
    t.string   "photo_l"
    t.decimal  "rate",                                                default: 85.0
    t.decimal  "sales_tax",                   precision: 8, scale: 3
    t.string   "setup",                                               default: "000010"
    t.string   "image"
    t.boolean  "pos",                                                 default: false
    t.boolean  "tou",                                                 default: false
    t.integer  "tz",                                                  default: 0
    t.boolean  "live",                                                default: false
    t.boolean  "paused",                                              default: true
    t.float    "latitude"
    t.float    "longitude"
    t.string   "ein"
    t.integer  "region_id"
    t.string   "pos_merchant_id"
    t.integer  "account_admin_id"
    t.tsvector "ftmeta"
    t.integer  "r_sys",                                               default: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
    t.integer  "payment_event",                                       default: 0
    t.string   "tender_type_id"
    t.string   "pos_sys"
    t.integer  "prime_amount"
    t.date     "prime_date"
    t.date     "contract_date"
  end

  add_index "merchants", ["ftmeta"], name: "merchants_ftsmeta_idx", using: :gin
  add_index "merchants", ["token", "active"], name: "index_merchants_on_token_and_active", using: :btree
  add_index "merchants", ["token"], name: "index_merchants_on_token", using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mock_payables", ["merchant_id"], name: "index_mock_payables_on_merchant_id", using: :btree

  create_table "mt_users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.string   "sex"
    t.date     "birthday"
    t.string   "password_digest"
    t.string   "remember_token",                                 null: false
    t.boolean  "admin",                          default: false
    t.integer  "confirm",                        default: 0
    t.datetime "reset_token_sent_at"
    t.string   "reset_token"
    t.boolean  "active",                         default: true
    t.integer  "db_user_id"
    t.string   "address"
    t.string   "city"
    t.string   "state",               limit: 2
    t.string   "zip",                 limit: 16
    t.string   "facebook_id"
    t.string   "twitter"
    t.string   "photo"
    t.string   "min_photo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
  end

  add_index "mt_users", ["affiliate_id"], name: "index_mt_users_on_affiliate_id", using: :btree
  add_index "mt_users", ["db_user_id"], name: "index_mt_users_on_db_user_id", using: :btree
  add_index "mt_users", ["email"], name: "index_mt_users_on_email", using: :btree
  add_index "mt_users", ["remember_token"], name: "index_mt_users_on_remember_token", using: :btree

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

  create_table "operations", force: true do |t|
    t.integer  "obj_id"
    t.integer  "user_id"
    t.integer  "status"
    t.text     "note"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of"
    t.string   "obj_type"
  end

  add_index "operations", ["obj_id"], name: "index_operations_on_obj_id", using: :btree
  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree

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
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_number"
  end

  add_index "payables", ["merchant_id", "payment_date"], name: "index_payables_on_merchant_id_and_payment_date", using: :btree
  add_index "payables", ["merchant_id"], name: "index_payables_on_merchant_id", using: :btree
  add_index "payables", ["status"], name: "index_payables_on_status", using: :btree

  create_table "payments", force: true do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "auth_date"
    t.string   "conf_num"
    t.integer  "m_transactions", default: 0
    t.integer  "m_amount",       default: 0
    t.integer  "u_transactions", default: 0
    t.integer  "u_amount",       default: 0
    t.integer  "total",          default: 0
    t.boolean  "paid",           default: false
    t.integer  "partner_id"
    t.string   "partner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "l_transactions", default: 0
    t.integer  "l_amount",       default: 0
    t.integer  "at_user_id"
  end

  add_index "payments", ["paid", "start_date"], name: "index_payments_on_paid_and_start_date", using: :btree
  add_index "payments", ["partner_id", "partner_type"], name: "index_payments_on_partner_id_and_partner_type", using: :btree

  create_table "pn_tokens", force: true do |t|
    t.integer  "user_id"
    t.string   "pn_token"
    t.string   "platform",   default: "ios"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "pn_tokens", ["platform", "pn_token"], name: "index_pn_tokens_on_platform_and_pn_token", using: :btree
  add_index "pn_tokens", ["user_id"], name: "index_pn_tokens_on_user_id", using: :btree

  create_table "progresses", force: true do |t|
    t.integer  "merchant_id"
    t.integer  "profile",     default: 1
    t.integer  "bank",        default: 0
    t.integer  "photo",       default: 0
    t.integer  "menu",        default: 0
    t.integer  "staff",       default: 0
    t.integer  "approval",    default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "progresses", ["merchant_id"], name: "index_progresses_on_merchant_id", using: :btree

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
  add_index "proto_joins", ["proto_id"], name: "index_proto_joins_on_proto_id", using: :btree
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

  add_index "protos", ["provider_id"], name: "index_protos_on_provider_id", using: :btree

  create_table "providers", force: true do |t|
    t.string   "name",                                       null: false
    t.string   "zinger"
    t.text     "description"
    t.string   "address"
    t.string   "city",            limit: 32
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 16
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "phone"
    t.string   "sales_tax"
    t.boolean  "active",                     default: true
    t.float    "latitude"
    t.float    "longitude"
    t.decimal  "rate",                       default: 85.0
    t.boolean  "menu_is_live",               default: false
    t.integer  "brand_id"
    t.integer  "building_id"
    t.string   "token"
    t.boolean  "tools",                      default: false
    t.string   "image"
    t.integer  "merchant_id"
    t.boolean  "live",                       default: false
    t.boolean  "paused",                     default: true
    t.string   "pos_merchant_id"
    t.integer  "region_id"
    t.integer  "r_sys",                      default: 2
    t.string   "photo_l"
    t.integer  "payment_plan",               default: 0
    t.integer  "payment_event",              default: 0
    t.string   "tender_type_id"
    t.string   "website"
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

  create_table "redemptions", force: true do |t|
    t.integer  "gift_id"
    t.integer  "amount",          default: 0
    t.string   "ticket_id"
    t.json     "req_json"
    t.json     "resp_json"
    t.integer  "type_of",         default: 0
    t.integer  "gift_prev_value", default: 0
    t.integer  "gift_next_value", default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "redemptions", ["gift_id"], name: "index_redemptions_on_gift_id", using: :btree

  create_table "registers", force: true do |t|
    t.integer  "gift_id"
    t.integer  "amount"
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "origin",       default: 0
    t.integer  "type_of",      default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
  end

  add_index "registers", ["created_at", "partner_id", "partner_type"], name: "index_registers_on_created_at_and_partner_id_and_partner_type", using: :btree
  add_index "registers", ["gift_id", "origin"], name: "index_registers_on_gift_id_and_origin", using: :btree

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

  create_table "sections", force: true do |t|
    t.string   "name"
    t.integer  "position"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["menu_id"], name: "index_sections_on_menu_id", using: :btree

  create_table "session_tokens", force: true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.integer  "device_id"
    t.string   "platform"
    t.string   "push"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "session_tokens", ["token"], name: "index_session_tokens_on_token", using: :btree

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

  add_index "settings", ["confirm_email_token"], name: "index_settings_on_confirm_email_token", using: :btree
  add_index "settings", ["user_id"], name: "index_settings_on_user_id", using: :btree

  create_table "sms_contacts", force: true do |t|
    t.integer  "gift_id"
    t.datetime "subscribed_date"
    t.string   "phone"
    t.integer  "service_id"
    t.string   "service"
    t.string   "textword"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaign_id"
  end

  add_index "sms_contacts", ["campaign_id", "textword", "gift_id"], name: "index_sms_contacts_on_campaign_id_and_textword_and_gift_id", using: :btree
  add_index "sms_contacts", ["gift_id"], name: "index_sms_contacts_on_gift_id", using: :btree
  add_index "sms_contacts", ["textword", "phone", "campaign_id"], name: "index_sms_contacts_on_textword_and_phone_and_campaign_id", using: :btree

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

  create_table "user_points", force: true do |t|
    t.integer  "user_id"
    t.integer  "region_id",  default: 0
    t.integer  "points",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_points", ["region_id", "points"], name: "index_user_points_on_region_id_and_points", using: :btree
  add_index "user_points", ["region_id", "user_id"], name: "index_user_points_on_region_id_and_user_id", using: :btree
  add_index "user_points", ["region_id"], name: "index_user_points_on_region_id", using: :btree

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

  add_index "user_socials", ["active", "identifier"], name: "index_user_socials_on_active_and_identifier", using: :btree
  add_index "user_socials", ["active"], name: "index_user_socials_on_active", using: :btree
  add_index "user_socials", ["type_of", "identifier"], name: "index_user_socials_on_type_of_and_identifier", using: :btree
  add_index "user_socials", ["user_id"], name: "index_user_socials_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email"
    t.string   "password_digest",                                null: false
    t.string   "remember_token"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "address"
    t.string   "address_2"
    t.string   "city",                limit: 20
    t.string   "state",               limit: 2
    t.string   "zip",                 limit: 16
    t.string   "phone"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "facebook_id"
    t.string   "handle"
    t.string   "twitter"
    t.boolean  "active",                         default: true
    t.string   "persona",                        default: ""
    t.string   "sex"
    t.boolean  "is_public"
    t.string   "iphone_photo"
    t.datetime "reset_token_sent_at"
    t.string   "reset_token"
    t.date     "birthday"
    t.string   "origin"
    t.string   "confirm",                        default: "00"
    t.boolean  "perm_deactive",                  default: false
    t.string   "cim_profile"
    t.tsvector "ftmeta"
    t.string   "affiliate_url_name"
  end

  add_index "users", ["active", "perm_deactive"], name: "index_users_on_active_and_perm_deactive", using: :btree
  add_index "users", ["ftmeta"], name: "users_ftsmeta_idx", using: :gin

end
