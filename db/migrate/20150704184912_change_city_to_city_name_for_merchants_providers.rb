class ChangeCityToCityNameForMerchantsProviders < ActiveRecord::Migration
  def change
  	rename_column :merchants, :city, :city_name
  	rename_column :providers, :city, :city_name
  end
end
