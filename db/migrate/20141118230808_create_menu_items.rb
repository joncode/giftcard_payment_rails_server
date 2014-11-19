class CreateMenuItems < ActiveRecord::Migration
  def change
    create_table :menu_items do |t|
	    t.string   :name
	    t.integer  :section_id
	    t.integer  :menu_id
	    t.text     :detail
	    t.string   :price
	    t.string   :photo
	    t.integer  :position
	    t.boolean  :active,      default: true
	    t.string   :price_promo
	    t.boolean  :standard,    default: false
	    t.boolean  :promo,       default: false
	    t.timestamps
    end
	add_index :menu_items, ["menu_id"], name: "index_menu_items_on_menu_id", using: :btree
	add_index :menu_items, ["section_id"], name: "index_menu_items_on_section_id", using: :btree
  end
end
