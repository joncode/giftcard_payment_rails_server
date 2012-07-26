class CreateMenuStrings < ActiveRecord::Migration
  def change
    create_table :menu_strings do |t|
      t.integer :version
      t.integer :provider_id
      t.integer :menu_id
      t.string  :full_address
      t.text    :menu

      t.timestamps
    end
  end
end
