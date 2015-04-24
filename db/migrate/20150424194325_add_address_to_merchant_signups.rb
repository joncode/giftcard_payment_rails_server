class AddAddressToMerchantSignups < ActiveRecord::Migration
  def change
    add_column :merchant_signups, :address, :string
  end
end
