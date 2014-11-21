class CreateMerchants < ActiveRecord::Migration
  def change
	  create_table :merchants, force: true do |t|
	    t.string   :name
	    t.string   :token
	    t.string   :zinger
	    t.text     :description
	    t.boolean  :active,                                              default: true
	    t.string   :address
	    t.string   :address_2
	    t.string   :city,             limit: 50
	    t.string   :state,            limit: 2
	    t.string   :zip,              limit: 16
	    t.string   :phone,            limit: 20
	    t.string   :email
	    t.string   :website
	    t.string   :facebook
	    t.string   :twitter
	    t.string   :photo
	    t.string   :photo_l
	    t.decimal  :rate,                        precision: 8, scale: 3
	    t.decimal  :sales_tax,                   precision: 8, scale: 3
	    t.string   :setup,                                               default: "000010"
	    t.string   :image
	    t.boolean  :pos,                                                 default: false
	    t.boolean  :tou,                                                 default: false
	    t.integer  :tz,                                                  default: 0
	    t.boolean  :live,                                                default: false
	    t.boolean  :paused,                                              default: true
	    t.float    :latitude
	    t.float    :longitude
	    t.string   :ein
	    t.integer  :region_id
	    t.integer  :pos_merchant_id
	    t.integer  :account_admin_id
	    t.tsvector :ftmeta
	    t.integer  :r_sys,                                               default: 2
	    t.timestamps
	  end
	  add_index :merchants, ["ftmeta"], name: "merchants_ftsmeta_idx", using: :gin
	  add_index :merchants, ["token", "active"], name: "index_merchants_on_token_and_active", using: :btree
	  add_index :merchants, ["token"], name: "index_merchants_on_token", using: :btree
  end
end
