class AddRegionNameToProvidersAndMerchants < ActiveRecord::Migration
  def change
  	add_column :providers, :region_name, :string
  	add_column :merchants, :region_name, :string
  end
end
