class AddProviderAndStatusIndexToGifts < ActiveRecord::Migration
  def change

  	add_index :gifts, [:provider_id, :status]
  end
end
