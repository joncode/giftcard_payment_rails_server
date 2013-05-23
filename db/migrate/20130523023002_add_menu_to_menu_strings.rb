class AddMenuToMenuStrings < ActiveRecord::Migration
  def change
    add_column :menu_strings, :menu, :text
  end
end
