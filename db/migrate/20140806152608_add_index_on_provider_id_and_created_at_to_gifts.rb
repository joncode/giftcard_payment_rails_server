class AddIndexOnProviderIdAndCreatedAtToGifts < ActiveRecord::Migration
  def change
  	add_index :gifts, [:provider_id, :created_at]
  end
end
