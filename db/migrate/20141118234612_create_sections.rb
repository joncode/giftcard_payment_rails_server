class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections do |t|
	    t.string   :name
	    t.integer  :position
	    t.integer  :menu_id
	    t.timestamps
    end
    add_index :sections, ["menu_id"], name: "index_sections_on_menu_id", using: :btree
  end
end
