class AddProviderFieldsToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :menu_is_live, :boolean, default: false
  	add_column :merchants, :brand_id , :integer
  	add_column :merchants, :building_id, :integer
  	add_column :merchants, :tools, :boolean, default: false
  	add_column :merchants, :payment_plan, :integer, default: 0
  end
end
