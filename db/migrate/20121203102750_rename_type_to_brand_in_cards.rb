class RenameTypeToBrandInCards < ActiveRecord::Migration
  def up
  	rename_column :cards, :type, :brand
  end

  def down
  	rename_column :cards, :brand, :type
  end
end
