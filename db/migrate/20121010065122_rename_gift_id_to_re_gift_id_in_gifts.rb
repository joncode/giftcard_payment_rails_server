class RenameGiftIdToReGiftIdInGifts < ActiveRecord::Migration
  def up
  	rename_column :gifts, :gift_id, :regift_id
  end

  def down
  	rename_column :gifts, :regift_id, :gift_id
  end
end
