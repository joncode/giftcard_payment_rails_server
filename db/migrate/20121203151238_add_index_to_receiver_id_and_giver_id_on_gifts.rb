class AddIndexToReceiverIdAndGiverIdOnGifts < ActiveRecord::Migration
  def up
  	add_index :gifts, :giver_id
  	add_index :gifts, :receiver_id
  	add_index :gifts, :provider_id
  end

  def down
  	remove_index :gifts, :giver_id
  	remove_index :gifts, :receiver_id
  	remove_index :gifts, :provider_id
  end
end
