class AddActiveIndexToProtos < ActiveRecord::Migration
  def change
  	remove_index :protos, :provider_id
  	add_index :protos, :active
  end
end
