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

ActiveRecord::Schema.define(version: 20161007232149) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "pgcrypto"
  enable_extension "uuid-ossp"

  create_table "affiliates", force: :cascade do |t|
    t.string   "first_name",         limit: 255
    t.string   "last_name",          limit: 255
    t.string   "email",              limit: 255
    t.string   "phone",              limit: 255
    t.string   "address",            limit: 255
    t.string   "state",              limit: 255
    t.string   "city",               limit: 255
    t.string   "zip",                limit: 255
    t.string   "url_name",           limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "total_merchants",                default: 0
    t.integer  "payout_merchants",               default: 0
    t.integer  "total_users",                    default: 0
    t.integer  "payout_users",                   default: 0
    t.integer  "payout_links",                   default: 0
    t.integer  "value_links",                    default: 0
    t.integer  "value_users",                    default: 0
    t.integer  "value_merchants",                default: 0
    t.integer  "purchase_links",                 default: 0
    t.integer  "purchase_users",                 default: 0
    t.integer  "purchase_merchants",             default: 0
    t.string   "company",            limit: 255
    t.string   "website_url",        limit: 255
    t.boolean  "active",                         default: true
    t.integer  "bank_id"
    t.integer  "menu_id"
    t.integer  "pos_merchant_id"
    t.integer  "promo_menu_id"
    t.integer  "tz",                             default: 0
    t.string   "features"
    t.string   "ccy",                limit: 6,   default: "USD"
  end

  add_index "affiliates", ["url_name"], name: "index_affiliates_on_url_name", using: :btree

  create_table "affiliates_gifts", id: false, force: :cascade do |t|
    t.integer "affiliate_id"
    t.integer "gift_id"
    t.integer "landing_page_id"
  end

  add_index "affiliates_gifts", ["affiliate_id"], name: "index_affiliates_gifts_on_affiliate_id", using: :btree
  add_index "affiliates_gifts", ["gift_id"], name: "index_affiliates_gifts_on_gift_id", using: :btree

  create_table "affiliations", force: :cascade do |t|
    t.integer  "affiliate_id"
    t.integer  "target_id"
    t.string   "target_type",  limit: 255
    t.string   "name",         limit: 255
    t.string   "address",      limit: 255
    t.integer  "payout",                   default: 0
    t.integer  "status",                   default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "affiliations", ["affiliate_id", "target_type"], name: "index_affiliations_on_affiliate_id_and_target_type", using: :btree
  add_index "affiliations", ["affiliate_id"], name: "index_affiliations_on_affiliate_id", using: :btree

  create_table "alert_contacts", force: :cascade do |t|
    t.integer  "note_id"
    t.string   "note_type"
    t.integer  "alert_id"
    t.string   "net"
    t.string   "net_id"
    t.string   "status",     default: "live"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "user_id"
    t.string   "user_type"
    t.boolean  "active",     default: true
  end

  create_table "alert_messages", force: :cascade do |t|
    t.integer  "alert_contact_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.string   "status",           default: "unsent"
    t.string   "reason"
    t.string   "msg"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.boolean  "active",           default: true
  end

  create_table "alerts", force: :cascade do |t|
    t.string   "name"
    t.string   "system"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "title"
    t.string   "detail"
    t.boolean  "active",     default: true
  end

  add_index "alerts", ["name"], name: "index_alerts_on_name", using: :btree

  create_table "answers", force: :cascade do |t|
    t.string   "answer",      limit: 255
    t.integer  "user_id"
    t.integer  "question_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "answers", ["question_id"], name: "index_answers_on_question_id", using: :btree
  add_index "answers", ["user_id"], name: "index_answers_on_user_id", using: :btree

  create_table "app_contacts", force: :cascade do |t|
    t.string   "network",    limit: 255
    t.string   "network_id", limit: 255
    t.string   "name",       limit: 255
    t.date     "birthday"
    t.string   "handle",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "at_users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "email",                  limit: 255
    t.string   "phone",                  limit: 255
    t.string   "sex",                    limit: 255
    t.date     "birthday"
    t.string   "password_digest",        limit: 255
    t.string   "remember_token",         limit: 255
    t.boolean  "admin",                              default: false
    t.string   "code",                   limit: 255
    t.integer  "confirm",                            default: 0
    t.datetime "reset_token_sent_at"
    t.string   "reset_token",            limit: 255
    t.boolean  "active",                             default: true
    t.integer  "db_user_id"
    t.string   "address",                limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 2
    t.string   "zip",                    limit: 16
    t.string   "photo",                  limit: 255
    t.string   "min_photo",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_login"
    t.integer  "time_zone",                          default: 0
    t.boolean  "acct",                               default: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "at_users", ["email"], name: "index_at_users_on_email", unique: true, using: :btree
  add_index "at_users", ["remember_token"], name: "index_at_users_on_remember_token", using: :btree
  add_index "at_users", ["reset_password_token"], name: "index_at_users_on_reset_password_token", unique: true, using: :btree

  create_table "at_users_socials", force: :cascade do |t|
    t.integer  "at_user_id"
    t.integer  "social_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attachinary_files", force: :cascade do |t|
    t.integer  "attachinariable_id"
    t.string   "attachinariable_type", limit: 255
    t.string   "scope",                limit: 255
    t.string   "public_id",            limit: 255
    t.string   "version",              limit: 255
    t.integer  "width"
    t.integer  "height"
    t.string   "format",               limit: 255
    t.string   "resource_type",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attachinary_files", ["attachinariable_type", "attachinariable_id", "scope"], name: "by_scoped_parent", using: :btree

  create_table "banks", force: :cascade do |t|
    t.integer  "merchant_id"
    t.string   "aba",                   limit: 255
    t.string   "account_number",        limit: 255
    t.string   "name",                  limit: 255
    t.string   "address",               limit: 255
    t.string   "city",                  limit: 50
    t.string   "state",                 limit: 2
    t.string   "zip",                   limit: 16
    t.string   "account_name",          limit: 255
    t.integer  "acct_type"
    t.string   "country",               limit: 255, default: "USA"
    t.string   "public_account_number", limit: 255
    t.string   "public_aba",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "banks", ["merchant_id"], name: "index_banks_on_merchant_id", using: :btree

  create_table "boomerangs", force: :cascade do |t|
  end

  create_table "brands", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "description", limit: 255
    t.string   "address",     limit: 255
    t.string   "city",        limit: 255
    t.string   "state",       limit: 255
    t.string   "phone",       limit: 255
    t.string   "website",     limit: 255
    t.string   "logo",        limit: 255
    t.string   "photo",       limit: 255
    t.string   "portrait",    limit: 255
    t.integer  "user_id"
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.integer  "owner_id"
    t.string   "next_view",   limit: 255
    t.boolean  "child",                   default: false
    t.boolean  "active",                  default: true
  end

  add_index "brands", ["active"], name: "index_brands_on_active", using: :btree

  create_table "bulk_contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bulk_emails", force: :cascade do |t|
    t.text     "data"
    t.boolean  "processed",   default: false
    t.integer  "proto_id"
    t.integer  "provider_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "at_user_id"
    t.integer  "merchant_id"
  end

  add_index "bulk_emails", ["at_user_id"], name: "index_bulk_emails_on_at_user_id", using: :btree
  add_index "bulk_emails", ["proto_id"], name: "index_bulk_emails_on_proto_id", using: :btree

  create_table "campaign_items", force: :cascade do |t|
    t.integer  "campaign_id"
    t.integer  "provider_id"
    t.integer  "giver_id"
    t.string   "giver_name",   limit: 255
    t.integer  "budget"
    t.integer  "reserve"
    t.text     "message"
    t.text     "shoppingCart"
    t.string   "value",        limit: 255
    t.string   "cost",         limit: 255
    t.date     "expires_at"
    t.integer  "expires_in"
    t.string   "textword",     limit: 255
    t.boolean  "contract"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "detail"
    t.integer  "merchant_id"
    t.boolean  "brand_card",               default: false
    t.datetime "scheduled_at"
  end

  add_index "campaign_items", ["campaign_id"], name: "index_campaign_items_on_campaign_id", using: :btree
  add_index "campaign_items", ["textword"], name: "index_campaign_items_on_textword", using: :btree

  create_table "campaigns", force: :cascade do |t|
    t.string   "type_of",        limit: 255
    t.string   "status",         limit: 255
    t.string   "name",           limit: 255
    t.text     "notes"
    t.date     "live_date"
    t.date     "close_date"
    t.date     "expire_date"
    t.integer  "purchaser_id"
    t.string   "purchaser_type", limit: 255
    t.string   "giver_name",     limit: 255
    t.string   "photo",          limit: 255
    t.integer  "budget"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "photo_path",     limit: 255
  end

  add_index "campaigns", ["close_date"], name: "index_campaigns_on_close_date", using: :btree

  create_table "cards", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "nickname",       limit: 255
    t.string   "name",           limit: 255
    t.string   "number_digest",  limit: 255
    t.string   "last_four",      limit: 255
    t.string   "month",          limit: 255
    t.string   "year",           limit: 255
    t.string   "csv",            limit: 255
    t.string   "brand",          limit: 255
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "cim_token",      limit: 255
    t.string   "zip",            limit: 255
    t.boolean  "active",                     default: true
    t.integer  "partner_id"
    t.string   "partner_type"
    t.string   "origin"
    t.integer  "client_id"
    t.string   "ccy",            limit: 6,   default: "USD"
    t.string   "trans_token"
    t.string   "country"
    t.string   "stripe_user_id"
    t.string   "stripe_id"
    t.string   "address"
    t.text     "resp_json"
  end

  add_index "cards", ["active"], name: "index_cards_on_active", using: :btree
  add_index "cards", ["user_id"], name: "index_cards_on_user_id", using: :btree

  create_table "clients", force: :cascade do |t|
    t.string   "name"
    t.string   "url_name"
    t.string   "download_url"
    t.string   "application_key"
    t.string   "detail"
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "platform",        default: 0
    t.boolean  "active",          default: true
    t.integer  "ecosystem",       default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "data_type",       default: 0
    t.integer  "data_id"
    t.integer  "clicks",          default: 0
  end

  add_index "clients", ["application_key", "active"], name: "index_clients_on_application_key_and_active", using: :btree
  add_index "clients", ["url_name", "active"], name: "index_clients_on_url_name_and_active", using: :btree

  create_table "contacts", force: :cascade do |t|
    t.integer  "brand_id"
    t.string   "address",    limit: 255
    t.string   "city",       limit: 255
    t.string   "state",      limit: 255
    t.string   "zip",        limit: 255
    t.string   "name",       limit: 255
    t.string   "email",      limit: 255
    t.string   "phone",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contacts", ["brand_id"], name: "index_contacts_on_brand_id", using: :btree

  create_table "contents", force: :cascade do |t|
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "client_id"
    t.integer  "content_id"
    t.string   "content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "contents", ["client_id", "content_id", "content_type"], name: "index_contents_on_client_id_and_content_id_and_content_type", using: :btree
  add_index "contents", ["client_id", "content_type"], name: "index_contents_on_client_id_and_content_type", using: :btree
  add_index "contents", ["partner_id", "partner_type", "content_type"], name: "index_contents_on_partner_id_and_partner_type_and_content_type", using: :btree

  create_table "credit_accounts", force: :cascade do |t|
    t.string   "owner",      limit: 255
    t.integer  "owner_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "debts", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type", limit: 255
    t.decimal  "amount",                 precision: 8, scale: 2
    t.decimal  "total",                  precision: 8, scale: 2
    t.string   "detail",     limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "dittos", force: :cascade do |t|
    t.text     "response_json"
    t.integer  "status"
    t.integer  "cat"
    t.integer  "notable_id"
    t.string   "notable_type",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "dittos", ["notable_id", "notable_type"], name: "index_dittos_on_notable_id_and_notable_type", using: :btree
  add_index "dittos", ["status"], name: "index_dittos_on_status", using: :btree

  create_table "friendships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "app_contact_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friendships", ["app_contact_id"], name: "index_friendships_on_app_contact_id", using: :btree
  add_index "friendships", ["user_id", "app_contact_id"], name: "index_friendships_on_user_id_and_app_contact_id", unique: true, using: :btree
  add_index "friendships", ["user_id"], name: "index_friendships_on_user_id", using: :btree

  create_table "gift_analytics", force: :cascade do |t|
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

  create_table "gift_items", force: :cascade do |t|
    t.integer "gift_id"
    t.integer "menu_item_id"
    t.string  "price",        limit: 255
    t.integer "quantity"
    t.string  "name",         limit: 255
    t.text    "detail"
    t.string  "ccy",          limit: 6,   default: "USD"
    t.integer "price_cents"
  end

  add_index "gift_items", ["gift_id"], name: "index_gift_items_on_gift_id", using: :btree

  create_table "gifts", force: :cascade do |t|
    t.string   "giver_name",     limit: 255
    t.string   "receiver_name",  limit: 255
    t.string   "provider_name",  limit: 255
    t.integer  "giver_id"
    t.integer  "receiver_id"
    t.string   "credit_card",    limit: 100
    t.integer  "provider_id"
    t.text     "message"
    t.string   "status",         limit: 255, default: "unpaid"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "receiver_phone", limit: 255
    t.string   "facebook_id",    limit: 255
    t.string   "receiver_email", limit: 255
    t.text     "shoppingCart"
    t.string   "twitter",        limit: 255
    t.string   "service",        limit: 255
    t.string   "order_num",      limit: 255
    t.integer  "cat",                        default: 0
    t.boolean  "active",                     default: true
    t.string   "pay_stat",       limit: 255
    t.datetime "redeemed_at"
    t.string   "server",         limit: 255
    t.integer  "payable_id"
    t.string   "payable_type",   limit: 255
    t.string   "giver_type",     limit: 255
    t.string   "value",          limit: 255
    t.datetime "expires_at"
    t.integer  "refund_id"
    t.string   "refund_type",    limit: 255
    t.string   "cost",           limit: 255
    t.text     "detail"
    t.tsvector "ftmeta"
    t.datetime "notified_at"
    t.datetime "new_token_at"
    t.integer  "token"
    t.integer  "balance"
    t.string   "origin",         limit: 255
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "client_id"
    t.integer  "rec_client_id"
    t.integer  "merchant_id"
    t.boolean  "brand_card",                 default: false
    t.datetime "scheduled_at"
    t.string   "ccy",            limit: 6,   default: "USD"
    t.string   "hex_id"
  end

  add_index "gifts", ["active", "pay_stat"], name: "index_gifts_on_active_and_pay_stat", using: :btree
  add_index "gifts", ["active"], name: "index_gifts_on_active", using: :btree
  add_index "gifts", ["cat"], name: "index_gifts_on_cat", using: :btree
  add_index "gifts", ["ftmeta"], name: "gifts_ftsmeta_idx", using: :gin
  add_index "gifts", ["giver_id"], name: "index_gifts_on_giver_id", using: :btree
  add_index "gifts", ["hex_id"], name: "index_gifts_on_hex_id", using: :btree
  add_index "gifts", ["merchant_id", "created_at"], name: "index_gifts_on_merchant_id_and_created_at", using: :btree
  add_index "gifts", ["merchant_id", "status"], name: "index_gifts_on_merchant_id_and_status", using: :btree
  add_index "gifts", ["merchant_id"], name: "index_gifts_on_merchant_id", using: :btree
  add_index "gifts", ["pay_stat"], name: "index_gifts_on_pay_stat", using: :btree
  add_index "gifts", ["payable_id", "payable_type"], name: "index_gifts_on_payable_id_and_payable_type", using: :btree
  add_index "gifts", ["receiver_id"], name: "index_gifts_on_receiver_id", using: :btree
  add_index "gifts", ["status"], name: "index_gifts_on_status", using: :btree

  create_table "invites", force: :cascade do |t|
    t.string   "invite_tkn",   limit: 255
    t.string   "email",        limit: 255
    t.integer  "mt_user_id"
    t.integer  "company_id"
    t.boolean  "active",                   default: true
    t.integer  "rank",                     default: 0
    t.boolean  "general",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "clearance",    limit: 225
    t.string   "company_type", limit: 255
  end

  add_index "invites", ["company_id"], name: "index_invites_on_company_id", using: :btree
  add_index "invites", ["invite_tkn"], name: "index_invites_on_invite_tkn", using: :btree
  add_index "invites", ["mt_user_id"], name: "index_invites_on_mt_user_id", using: :btree

  create_table "landing_pages", force: :cascade do |t|
    t.integer  "campaign_id"
    t.integer  "affiliate_id"
    t.string   "title",             limit: 255
    t.string   "banner_photo_url",  limit: 255
    t.integer  "example_item_id"
    t.json     "page_json"
    t.string   "sponsor_photo_url", limit: 255
    t.string   "link",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "clicks",                        default: 0
    t.integer  "users",                         default: 0
    t.integer  "gifts",                         default: 0
  end

  add_index "landing_pages", ["link"], name: "index_landing_pages_on_link", using: :btree

  create_table "legals", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "business_tax_id"
    t.string   "personal_id"
    t.string   "entity_type",     default: "company"
    t.string   "date_of_birth"
    t.integer  "company_id"
    t.string   "company_type"
    t.string   "merchant_ein"
    t.boolean  "tos"
    t.datetime "tos_accept_at"
    t.inet     "tos_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "licenses", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.string   "status"
    t.string   "partner_type"
    t.integer  "partner_id"
    t.date     "live_at"
    t.date     "expires_at"
    t.string   "origin"
    t.string   "name"
    t.string   "detail"
    t.string   "detail_action"
    t.string   "amount_action"
    t.integer  "amount"
    t.float    "percent"
    t.integer  "units"
    t.string   "ccy"
    t.string   "recurring_type"
    t.string   "weekday"
    t.integer  "process_month"
    t.integer  "process_day"
    t.integer  "notify_day"
    t.string   "charge_type"
    t.integer  "charge_id"
    t.text     "note"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "licenses", ["partner_type", "partner_id"], name: "index_licenses_on_partner_type_and_partner_id", using: :btree
  add_index "licenses", ["status"], name: "index_licenses_on_status", using: :btree

  create_table "list_graphs", force: :cascade do |t|
    t.integer  "list_id"
    t.integer  "item_id"
    t.string   "item_type"
    t.integer  "position"
    t.boolean  "active",     default: true
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "list_graphs", ["list_id", "active"], name: "index_list_graphs_on_list_id_and_active", using: :btree
  add_index "list_graphs", ["list_id"], name: "index_list_graphs_on_list_id", using: :btree

  create_table "list_items", force: :cascade do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "list_step_id"
    t.string   "state",        default: ""
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "list_steps", force: :cascade do |t|
    t.string   "name"
    t.string   "type_of"
    t.string   "owner_type"
    t.integer  "position",   default: 0
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "lists", force: :cascade do |t|
    t.string   "owner_type"
    t.integer  "owner_id"
    t.string   "token"
    t.boolean  "active",      default: true
    t.string   "template"
    t.string   "name"
    t.string   "zinger"
    t.text     "detail"
    t.string   "photo"
    t.string   "logo"
    t.integer  "total_items"
    t.string   "item_type"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "lists", ["owner_id", "owner_type"], name: "index_lists_on_owner_id_and_owner_type", using: :btree
  add_index "lists", ["token"], name: "index_lists_on_token", using: :btree

  create_table "menu_items", force: :cascade do |t|
    t.string   "name",              limit: 255
    t.integer  "section_id"
    t.integer  "menu_id"
    t.text     "detail"
    t.string   "price",             limit: 255
    t.string   "photo",             limit: 255
    t.integer  "position"
    t.boolean  "active",                        default: true
    t.string   "price_promo",       limit: 255
    t.boolean  "standard",                      default: false
    t.boolean  "promo",                         default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "pos_item_id"
    t.string   "ccy",               limit: 6,   default: "USD"
    t.integer  "price_cents"
    t.integer  "price_promo_cents"
    t.string   "token"
  end

  add_index "menu_items", ["menu_id"], name: "index_menu_items_on_menu_id", using: :btree
  add_index "menu_items", ["section_id"], name: "index_menu_items_on_section_id", using: :btree

  create_table "menu_strings", force: :cascade do |t|
    t.integer  "version"
    t.integer  "provider_id"
    t.string   "full_address",  limit: 255
    t.text     "data",                      null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "sections_json", limit: 255
    t.text     "menu"
    t.integer  "merchant_id"
  end

  add_index "menu_strings", ["merchant_id"], name: "index_menu_strings_on_merchant_id", using: :btree
  add_index "menu_strings", ["provider_id"], name: "index_menu_strings_on_provider_id", using: :btree

  create_table "menus", force: :cascade do |t|
    t.string   "merchant_token", limit: 255
    t.text     "json"
    t.integer  "merchant_id"
    t.integer  "type_of"
    t.boolean  "edited"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "menus", ["merchant_id"], name: "index_menus_on_merchant_id", using: :btree
  add_index "menus", ["merchant_token"], name: "index_menus_on_merchant_token", using: :btree

  create_table "merchant_signups", force: :cascade do |t|
    t.string   "name",                 limit: 255
    t.string   "position",             limit: 255
    t.string   "email",                limit: 255
    t.string   "phone",                limit: 255
    t.string   "website",              limit: 255
    t.string   "venue_name",           limit: 255
    t.string   "venue_url",            limit: 255
    t.string   "point_of_sale_system", limit: 255
    t.string   "message",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "active",                           default: true
    t.string   "address",              limit: 255
  end

  add_index "merchant_signups", ["active"], name: "index_merchant_signups_on_active", using: :btree

  create_table "merchants", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "token",            limit: 255
    t.string   "zinger",           limit: 255
    t.text     "description"
    t.boolean  "active",                                               default: true
    t.string   "address",          limit: 255
    t.string   "address_2",        limit: 255
    t.string   "city_name",        limit: 50
    t.string   "state",            limit: 2
    t.string   "zip",              limit: 16
    t.string   "phone",            limit: 20
    t.string   "email",            limit: 255
    t.string   "website",          limit: 255
    t.string   "facebook",         limit: 255
    t.string   "twitter",          limit: 255
    t.string   "photo",            limit: 255
    t.string   "photo_l",          limit: 255
    t.decimal  "rate",                                                 default: 85.0
    t.decimal  "sales_tax",                    precision: 8, scale: 3
    t.string   "setup",            limit: 255,                         default: "000010"
    t.string   "image",            limit: 255
    t.boolean  "pos",                                                  default: false
    t.boolean  "tou",                                                  default: false
    t.integer  "tz",                                                   default: 0
    t.boolean  "live",                                                 default: false
    t.boolean  "paused",                                               default: true
    t.float    "latitude"
    t.float    "longitude"
    t.string   "ein",              limit: 255
    t.integer  "region_id"
    t.string   "pos_merchant_id",  limit: 255
    t.integer  "account_admin_id"
    t.tsvector "ftmeta"
    t.integer  "r_sys",                                                default: 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
    t.integer  "payment_event",                                        default: 0
    t.string   "tender_type_id",   limit: 255
    t.string   "pos_sys",          limit: 255
    t.integer  "prime_amount"
    t.date     "prime_date"
    t.date     "contract_date"
    t.string   "signup_email",     limit: 255
    t.string   "signup_name",      limit: 255
    t.integer  "city_id"
    t.string   "region_name",      limit: 255
    t.integer  "bank_id"
    t.boolean  "menu_is_live",                                         default: false
    t.integer  "brand_id"
    t.integer  "building_id"
    t.boolean  "tools",                                                default: false
    t.integer  "payment_plan",                                         default: 0
    t.integer  "menu_id"
    t.integer  "promo_menu_id"
    t.integer  "client_id"
    t.boolean  "pos_direct",                                           default: false
    t.string   "ccy",              limit: 6,                           default: "USD"
    t.date     "live_at"
  end

  add_index "merchants", ["ftmeta"], name: "merchants_ftsmeta_idx", using: :gin
  add_index "merchants", ["token", "active"], name: "index_merchants_on_token_and_active", using: :btree
  add_index "merchants", ["token"], name: "index_merchants_on_token", using: :btree

  create_table "merchants_regions", id: false, force: :cascade do |t|
    t.integer "region_id",   null: false
    t.integer "merchant_id", null: false
  end

  add_index "merchants_regions", ["region_id"], name: "index_merchants_regions_on_region_id", using: :btree

  create_table "mock_payables", force: :cascade do |t|
    t.decimal  "amount"
    t.integer  "status",                        default: 0
    t.integer  "merchant_id"
    t.integer  "provider_id"
    t.string   "name",              limit: 255
    t.string   "address",           limit: 255
    t.integer  "user_id"
    t.string   "last_payment",      limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.text     "json_ary_gift_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "mock_payables", ["merchant_id"], name: "index_mock_payables_on_merchant_id", using: :btree

  create_table "mt_users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "email",                  limit: 255
    t.string   "phone",                  limit: 255
    t.string   "sex",                    limit: 255
    t.date     "birthday"
    t.string   "password_digest",        limit: 255
    t.string   "remember_token",         limit: 255
    t.boolean  "admin",                              default: false
    t.integer  "confirm",                            default: 0
    t.datetime "reset_token_sent_at"
    t.string   "reset_token",            limit: 255
    t.boolean  "active",                             default: true
    t.integer  "db_user_id"
    t.string   "address",                limit: 255
    t.string   "city",                   limit: 255
    t.string   "state",                  limit: 2
    t.string   "zip",                    limit: 16
    t.string   "facebook_id",            limit: 255
    t.string   "twitter",                limit: 255
    t.string   "photo",                  limit: 255
    t.string   "min_photo",              limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "affiliate_id"
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
  end

  add_index "mt_users", ["affiliate_id"], name: "index_mt_users_on_affiliate_id", using: :btree
  add_index "mt_users", ["db_user_id"], name: "index_mt_users_on_db_user_id", using: :btree
  add_index "mt_users", ["email"], name: "index_mt_users_on_email", using: :btree
  add_index "mt_users", ["remember_token"], name: "index_mt_users_on_remember_token", using: :btree
  add_index "mt_users", ["reset_password_token"], name: "index_mt_users_on_reset_password_token", unique: true, using: :btree

  create_table "oauths", force: :cascade do |t|
    t.integer  "gift_id"
    t.string   "token",      limit: 255
    t.string   "secret",     limit: 255
    t.string   "network",    limit: 255
    t.string   "network_id", limit: 255
    t.string   "handle",     limit: 255
    t.string   "photo",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
  end

  create_table "operations", force: :cascade do |t|
    t.integer  "obj_id"
    t.integer  "user_id"
    t.integer  "status"
    t.text     "note"
    t.text     "response"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type_of",    limit: 255
    t.string   "obj_type",   limit: 255
  end

  add_index "operations", ["obj_id"], name: "index_operations_on_obj_id", using: :btree
  add_index "operations", ["user_id"], name: "index_operations_on_user_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "redeem_id"
    t.integer  "gift_id"
    t.string   "redeem_code",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "server_code",     limit: 255
    t.integer  "server_id"
    t.integer  "provider_id"
    t.integer  "employee_id"
    t.integer  "pos_merchant_id"
    t.string   "ticket_value",    limit: 255
    t.string   "ticket_item_ids", limit: 255
  end

  add_index "orders", ["gift_id"], name: "index_orders_on_gift_id", using: :btree

  create_table "payables", force: :cascade do |t|
    t.decimal  "amount"
    t.integer  "status",                          default: 0
    t.integer  "merchant_id"
    t.integer  "provider_id"
    t.string   "name",                limit: 255
    t.string   "address",             limit: 255
    t.integer  "user_id"
    t.string   "last_payment",        limit: 255
    t.datetime "start_date"
    t.string   "payment_date",        limit: 255
    t.datetime "end_date"
    t.text     "json_ary_gift_ids"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "confirmation_number", limit: 255
  end

  add_index "payables", ["merchant_id", "payment_date"], name: "index_payables_on_merchant_id_and_payment_date", using: :btree
  add_index "payables", ["merchant_id"], name: "index_payables_on_merchant_id", using: :btree
  add_index "payables", ["status"], name: "index_payables_on_status", using: :btree

  create_table "payments", force: :cascade do |t|
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "auth_date"
    t.string   "conf_num",       limit: 255
    t.integer  "m_transactions",             default: 0
    t.integer  "m_amount",                   default: 0
    t.integer  "u_transactions",             default: 0
    t.integer  "u_amount",                   default: 0
    t.integer  "total",                      default: 0
    t.boolean  "paid",                       default: false
    t.integer  "partner_id"
    t.string   "partner_type",   limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "l_transactions",             default: 0
    t.integer  "l_amount",                   default: 0
    t.integer  "at_user_id"
    t.integer  "bank_id"
    t.integer  "previous_total",             default: 0
    t.integer  "revenue",                    default: 0
    t.integer  "refund",                     default: 0
    t.integer  "payment_amount",             default: 0
    t.string   "type_of",                    default: "payment"
  end

  add_index "payments", ["bank_id", "start_date"], name: "index_payments_on_bank_id_and_start_date", using: :btree
  add_index "payments", ["paid", "start_date"], name: "index_payments_on_paid_and_start_date", using: :btree
  add_index "payments", ["partner_id", "partner_type"], name: "index_payments_on_partner_id_and_partner_type", using: :btree

  create_table "place_graphs", force: :cascade do |t|
    t.integer  "place_id"
    t.string   "place_type"
    t.integer  "parent_id"
    t.string   "parent_type"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "place_graphs", ["parent_id"], name: "index_place_graphs_on_parent_id", using: :btree
  add_index "place_graphs", ["place_id", "parent_id"], name: "index_place_graphs_on_place_id_and_parent_id", unique: true, using: :btree
  add_index "place_graphs", ["place_id", "parent_type"], name: "index_place_graphs_on_place_id_and_parent_type", using: :btree
  add_index "place_graphs", ["place_id"], name: "index_place_graphs_on_place_id", using: :btree
  add_index "place_graphs", ["place_type", "parent_id"], name: "index_place_graphs_on_place_type_and_parent_id", using: :btree

  create_table "places", force: :cascade do |t|
    t.string   "abbr"
    t.string   "name"
    t.string   "detail"
    t.string   "photo"
    t.boolean  "active",        default: true
    t.boolean  "unique",        default: true
    t.string   "type_of"
    t.string   "sub_type"
    t.float    "latitude"
    t.float    "longitude"
    t.float    "min_latitude"
    t.float    "min_longitude"
    t.float    "max_latitude"
    t.float    "max_longitude"
    t.float    "xaxis"
    t.float    "yaxis"
    t.float    "zaxis"
    t.string   "ccy"
    t.string   "tz"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "places", ["abbr", "type_of"], name: "index_places_on_abbr_and_type_of", using: :btree
  add_index "places", ["abbr"], name: "index_places_on_abbr", using: :btree
  add_index "places", ["type_of"], name: "index_places_on_type_of", using: :btree

  create_table "pn_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "pn_token",     limit: 255
    t.string   "platform",     limit: 255, default: "ios"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "canonical_id"
    t.string   "device_id"
  end

  add_index "pn_tokens", ["platform", "pn_token"], name: "index_pn_tokens_on_platform_and_pn_token", using: :btree
  add_index "pn_tokens", ["user_id"], name: "index_pn_tokens_on_user_id", using: :btree

  create_table "progresses", force: :cascade do |t|
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

  create_table "proto_joins", force: :cascade do |t|
    t.integer  "proto_id"
    t.integer  "receivable_id"
    t.string   "receivable_type", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "gift_id"
    t.string   "rec_name",        limit: 255
    t.integer  "send_user_id"
    t.string   "send_user_type"
  end

  add_index "proto_joins", ["gift_id"], name: "index_proto_joins_on_gift_id", using: :btree
  add_index "proto_joins", ["proto_id"], name: "index_proto_joins_on_proto_id", using: :btree
  add_index "proto_joins", ["receivable_id", "proto_id"], name: "index_proto_joins_on_receivable_id_and_proto_id", using: :btree
  add_index "proto_joins", ["receivable_id", "receivable_type"], name: "index_proto_joins_on_receivable_id_and_receivable_type", using: :btree

  create_table "protos", force: :cascade do |t|
    t.text     "message"
    t.text     "detail"
    t.text     "shoppingCart"
    t.string   "value",         limit: 255
    t.string   "cost",          limit: 255
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "giver_id"
    t.string   "giver_type",    limit: 255
    t.string   "giver_name",    limit: 255
    t.integer  "provider_id"
    t.string   "provider_name", limit: 255
    t.integer  "cat"
    t.integer  "contacts",                  default: 0
    t.integer  "processed",                 default: 0
    t.integer  "merchant_id"
    t.boolean  "split",                     default: false
    t.datetime "scheduled_at"
    t.string   "ccy",           limit: 6,   default: "USD"
    t.boolean  "quick",                     default: false
    t.integer  "expires_in"
    t.integer  "value_cents"
    t.integer  "cost_cents"
    t.string   "title"
    t.string   "desc"
    t.boolean  "camp",                      default: false
    t.boolean  "active",                    default: true
    t.boolean  "live",                      default: true
    t.string   "delivery"
    t.string   "promo_code"
    t.integer  "maximum"
    t.integer  "start_in"
  end

  add_index "protos", ["merchant_id"], name: "index_protos_on_merchant_id", using: :btree
  add_index "protos", ["provider_id"], name: "index_protos_on_provider_id", using: :btree

  create_table "providers", force: :cascade do |t|
    t.string   "name",            limit: 255,                 null: false
    t.string   "zinger",          limit: 255
    t.text     "description"
    t.string   "address",         limit: 255
    t.string   "city_name",       limit: 32
    t.string   "state",           limit: 2
    t.string   "zip",             limit: 16
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.string   "phone",           limit: 255
    t.string   "sales_tax",       limit: 255
    t.boolean  "active",                      default: true
    t.float    "latitude"
    t.float    "longitude"
    t.decimal  "rate",                        default: 85.0
    t.boolean  "menu_is_live",                default: false
    t.integer  "brand_id"
    t.integer  "building_id"
    t.string   "token",           limit: 255
    t.boolean  "tools",                       default: false
    t.string   "image",           limit: 255
    t.integer  "merchant_id"
    t.boolean  "live",                        default: false
    t.boolean  "paused",                      default: true
    t.string   "pos_merchant_id", limit: 255
    t.integer  "region_id"
    t.integer  "r_sys",                       default: 2
    t.string   "photo_l",         limit: 255
    t.integer  "payment_plan",                default: 0
    t.integer  "payment_event",               default: 0
    t.string   "tender_type_id",  limit: 255
    t.string   "website",         limit: 255
    t.integer  "city_id"
    t.string   "region_name",     limit: 255
  end

  add_index "providers", ["active", "paused", "city_name"], name: "index_providers_on_active_and_paused_and_city_name", using: :btree
  add_index "providers", ["city_name"], name: "index_providers_on_city_name", using: :btree
  add_index "providers", ["merchant_id"], name: "index_providers_on_merchant_id", using: :btree
  add_index "providers", ["pos_merchant_id"], name: "index_providers_on_pos_merchant_id", using: :btree
  add_index "providers", ["region_id"], name: "index_providers_on_region_id", using: :btree
  add_index "providers", ["token"], name: "index_providers_on_token", using: :btree

  create_table "providers_socials", id: false, force: :cascade do |t|
    t.integer "provider_id"
    t.integer "social_id",   null: false
    t.integer "merchant_id"
  end

  add_index "providers_socials", ["merchant_id", "social_id"], name: "index_providers_socials_on_merchant_id_and_social_id", unique: true, using: :btree
  add_index "providers_socials", ["merchant_id"], name: "index_providers_socials_on_merchant_id", using: :btree
  add_index "providers_socials", ["provider_id"], name: "index_providers_socials_on_provider_id", using: :btree

  create_table "providers_tags", id: false, force: :cascade do |t|
    t.integer "provider_id"
    t.integer "tag_id"
  end

  add_index "providers_tags", ["provider_id"], name: "index_providers_tags_on_provider_id", using: :btree
  add_index "providers_tags", ["tag_id"], name: "index_providers_tags_on_tag_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string "left",  limit: 255
    t.string "right", limit: 255
  end

  create_table "redeems", force: :cascade do |t|
    t.integer  "gift_id"
    t.string   "redeem_code",     limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.integer  "pos_merchant_id"
  end

  add_index "redeems", ["gift_id"], name: "index_redeems_on_gift_id", using: :btree

  create_table "redemptions", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "amount",                      default: 0
    t.string   "ticket_id",       limit: 255
    t.json     "req_json"
    t.json     "resp_json"
    t.integer  "type_of",                     default: 0
    t.integer  "gift_prev_value",             default: 0
    t.integer  "gift_next_value",             default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "merchant_id"
    t.string   "status",                      default: "done"
    t.integer  "r_sys"
    t.integer  "client_id"
    t.integer  "token"
    t.datetime "new_token_at"
    t.string   "hex_id"
    t.boolean  "active",                      default: true
    t.json     "start_req"
    t.json     "start_res"
    t.datetime "request_at"
    t.datetime "response_at"
  end

  add_index "redemptions", ["gift_id", "status", "active"], name: "index_redemptions_on_gift_id_and_status_and_active", using: :btree
  add_index "redemptions", ["gift_id"], name: "index_redemptions_on_gift_id", using: :btree
  add_index "redemptions", ["hex_id"], name: "index_redemptions_on_hex_id", using: :btree
  add_index "redemptions", ["token", "status", "active"], name: "index_redemptions_on_token_and_status_and_active", using: :btree

  create_table "regions", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "detail",     limit: 255
    t.integer  "state_id"
    t.integer  "city_id"
    t.string   "photo",      limit: 255
    t.boolean  "active",                 default: true
    t.integer  "type_of",                default: 0
    t.string   "token",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
  end

  add_index "regions", ["active"], name: "index_regions_on_active", using: :btree
  add_index "regions", ["city_id", "active"], name: "index_regions_on_city_id_and_active", using: :btree

  create_table "registers", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "amount"
    t.integer  "partner_id"
    t.string   "partner_type", limit: 255
    t.integer  "origin",                   default: 0
    t.integer  "type_of",                  default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "payment_id"
    t.string   "ccy",          limit: 6,   default: "USD"
    t.string   "note"
    t.uuid     "license_id"
  end

  add_index "registers", ["created_at", "partner_id", "partner_type"], name: "index_registers_on_created_at_and_partner_id_and_partner_type", using: :btree
  add_index "registers", ["gift_id", "origin"], name: "index_registers_on_gift_id_and_origin", using: :btree

  create_table "relationships", force: :cascade do |t|
    t.integer  "follower_id"
    t.integer  "followed_id"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "pushed",      default: false
  end

  add_index "relationships", ["followed_id"], name: "index_relationships_on_followed_id", using: :btree
  add_index "relationships", ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true, using: :btree
  add_index "relationships", ["follower_id"], name: "index_relationships_on_follower_id", using: :btree

  create_table "sales", force: :cascade do |t|
    t.integer  "gift_id"
    t.integer  "giver_id"
    t.integer  "card_id"
    t.integer  "provider_id"
    t.string   "transaction_id", limit: 255
    t.decimal  "revenue"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.text     "resp_json"
    t.text     "req_json"
    t.integer  "resp_code"
    t.string   "reason_text",    limit: 255
    t.integer  "reason_code"
    t.integer  "merchant_id"
    t.integer  "revenue_cents"
    t.string   "gateway"
  end

  add_index "sales", ["merchant_id"], name: "index_sales_on_merchant_id", using: :btree
  add_index "sales", ["provider_id"], name: "index_sales_on_provider_id", using: :btree

  create_table "sections", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "position"
    t.integer  "menu_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sections", ["menu_id"], name: "index_sections_on_menu_id", using: :btree

  create_table "session_tokens", force: :cascade do |t|
    t.string   "token",        limit: 255
    t.integer  "user_id"
    t.string   "device_id"
    t.string   "platform",     limit: 255
    t.string   "push",         limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "origin"
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "client_id"
    t.datetime "destroyed_at"
    t.integer  "count",                    default: 0
  end

  add_index "session_tokens", ["token"], name: "index_session_tokens_on_token", using: :btree

  create_table "settings", force: :cascade do |t|
    t.integer  "user_id"
    t.boolean  "email_invoice",                            default: true
    t.boolean  "email_redeem",                             default: true
    t.boolean  "email_invite",                             default: true
    t.boolean  "email_follow_up",                          default: true
    t.boolean  "email_receiver_new",                       default: true
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.string   "confirm_email_token",          limit: 255
    t.string   "confirm_phone_token",          limit: 255
    t.string   "reset_token",                  limit: 255
    t.boolean  "confirm_phone_flag",                       default: false
    t.boolean  "confirm_email_flag",                       default: false
    t.datetime "confirm_phone_token_sent_at"
    t.datetime "confirm_email_token_sent_at"
    t.datetime "reset_token_sent_at"
    t.boolean  "email_reminder_gift_receiver",             default: true
    t.boolean  "email_reminder_gift_giver",                default: true
  end

  add_index "settings", ["confirm_email_token"], name: "index_settings_on_confirm_email_token", using: :btree
  add_index "settings", ["user_id"], name: "index_settings_on_user_id", using: :btree

  create_table "shares", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "menu_item_id"
    t.string   "user_action"
    t.string   "network_id"
    t.integer  "count",        default: 0
    t.integer  "gift_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sms_contacts", force: :cascade do |t|
    t.integer  "gift_id"
    t.datetime "subscribed_date"
    t.string   "phone",           limit: 255
    t.integer  "service_id"
    t.string   "service",         limit: 255
    t.string   "textword",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "campaign_id"
  end

  add_index "sms_contacts", ["campaign_id", "textword", "gift_id"], name: "index_sms_contacts_on_campaign_id_and_textword_and_gift_id", using: :btree
  add_index "sms_contacts", ["gift_id"], name: "index_sms_contacts_on_gift_id", using: :btree
  add_index "sms_contacts", ["textword", "phone", "campaign_id"], name: "index_sms_contacts_on_textword_and_phone_and_campaign_id", using: :btree

  create_table "socials", force: :cascade do |t|
    t.string   "network_id", limit: 255
    t.string   "network",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 255
  end

  add_index "socials", ["network_id", "network"], name: "index_socials_on_network_id_and_network", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "user_points", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "region_id",  default: 0
    t.integer  "points",     default: 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_points", ["region_id", "points"], name: "index_user_points_on_region_id_and_points", using: :btree
  add_index "user_points", ["region_id", "user_id"], name: "index_user_points_on_region_id_and_user_id", using: :btree
  add_index "user_points", ["region_id"], name: "index_user_points_on_region_id", using: :btree

  create_table "user_socials", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "type_of",    limit: 255
    t.string   "identifier", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
    t.boolean  "active",                 default: true
    t.boolean  "subscribed",             default: false
    t.string   "name",       limit: 255
    t.date     "birthday"
    t.string   "handle",     limit: 255
    t.string   "status",                 default: "live"
    t.string   "msg"
    t.string   "code"
  end

  add_index "user_socials", ["active", "identifier"], name: "index_user_socials_on_active_and_identifier", using: :btree
  add_index "user_socials", ["active"], name: "index_user_socials_on_active", using: :btree
  add_index "user_socials", ["type_of", "identifier"], name: "index_user_socials_on_type_of_and_identifier", using: :btree
  add_index "user_socials", ["user_id"], name: "index_user_socials_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               limit: 255
    t.string   "password_digest",     limit: 255,                 null: false
    t.string   "remember_token",      limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "address",             limit: 255
    t.string   "address_2",           limit: 255
    t.string   "city",                limit: 20
    t.string   "state",               limit: 2
    t.string   "zip",                 limit: 16
    t.string   "phone",               limit: 255
    t.string   "first_name",          limit: 255
    t.string   "last_name",           limit: 255
    t.string   "facebook_id",         limit: 255
    t.string   "handle",              limit: 255
    t.string   "twitter",             limit: 255
    t.boolean  "active",                          default: true
    t.string   "persona",             limit: 255, default: ""
    t.string   "sex",                 limit: 255
    t.boolean  "is_public"
    t.string   "iphone_photo",        limit: 255
    t.datetime "reset_token_sent_at"
    t.string   "reset_token",         limit: 255
    t.date     "birthday"
    t.string   "origin",              limit: 255
    t.string   "confirm",             limit: 255, default: "00"
    t.boolean  "perm_deactive",                   default: false
    t.string   "cim_profile",         limit: 255
    t.tsvector "ftmeta"
    t.string   "affiliate_url_name",  limit: 255
    t.integer  "partner_id"
    t.string   "partner_type"
    t.integer  "client_id"
    t.string   "stripe_id"
  end

  add_index "users", ["active", "perm_deactive"], name: "index_users_on_active_and_perm_deactive", using: :btree
  add_index "users", ["ftmeta"], name: "users_ftsmeta_idx", using: :gin

end
