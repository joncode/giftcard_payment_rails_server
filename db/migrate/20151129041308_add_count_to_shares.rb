class AddCountToShares < ActiveRecord::Migration
  def change
  	add_column :shares, :count, :integer, default: 0
  end
end
