class AddGiftIdToShares < ActiveRecord::Migration
  def change
  	add_column :shares, :gift_id, :integer
  end
end
