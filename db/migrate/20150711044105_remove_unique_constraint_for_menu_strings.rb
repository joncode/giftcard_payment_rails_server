class RemoveUniqueConstraintForMenuStrings < ActiveRecord::Migration
  def up

	change_column :menu_strings, :provider_id, :integer, null: true
  end

  def down
	change_column :menu_strings, :provider_id, :integer, null: false
  end
end
