class AddIndexToProviderIdOnEmployees < ActiveRecord::Migration
  def up
  	add_index :employees, :provider_id
  end

  def down
  	remove_index :employees, :provider_id
  end
end
