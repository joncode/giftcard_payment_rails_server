class AddCityIdToMerchants < ActiveRecord::Migration
  def change
    add_column :merchants, :city_id, :integer
    add_column :providers, :city_id, :integer
    set_city_id_from_current_region_id
  end

  def set_city_id_from_current_region_id
  	Merchant.unscoped.all.each { |m| m.update(city_id: m.region_id)}
  	Provider.unscoped.all.each { |p| p.update(city_id: p.region_id)}
  end
end
