class AddSectionsJsonToMenuStrings < ActiveRecord::Migration
  def change
    add_column :menu_strings, :sections_json, :string
  end
end
