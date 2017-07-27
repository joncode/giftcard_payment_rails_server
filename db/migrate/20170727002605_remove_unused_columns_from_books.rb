class RemoveUnusedColumnsFromBooks < ActiveRecord::Migration
  def change
  	remove_column :books, :members, :json
  	remove_column :books, :photos, :json
  	remove_column :books, :price, :integer
  	remove_column :books, :price_wine, :integer
  end
end
