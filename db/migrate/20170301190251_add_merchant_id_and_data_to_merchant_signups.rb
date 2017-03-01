class AddMerchantIdAndDataToMerchantSignups < ActiveRecord::Migration
  def change
    add_column :merchant_signups, :merchant_id, :integer
    add_column :merchant_signups, :pos_merchant_id, :string
    add_column :merchant_signups, :device_id, :string
    add_column :merchant_signups, :data, :json
  end
end
