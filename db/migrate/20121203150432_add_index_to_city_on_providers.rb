class AddIndexToCityOnProviders < ActiveRecord::Migration
  def up
  	add_index :providers, :city
  end

  def down
  	remove_index :providers, :city
  end
end
