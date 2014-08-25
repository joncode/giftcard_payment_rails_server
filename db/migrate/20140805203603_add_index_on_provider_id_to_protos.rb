class AddIndexOnProviderIdToProtos < ActiveRecord::Migration
  def change
  	add_index :protos, :provider_id
  end
end
