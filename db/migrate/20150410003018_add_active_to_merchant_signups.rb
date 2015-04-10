class AddActiveToMerchantSignups < ActiveRecord::Migration
  def change
    add_column :merchant_signups, :active, :boolean, default: true
  	add_index :merchant_signups, :active
  end
end
