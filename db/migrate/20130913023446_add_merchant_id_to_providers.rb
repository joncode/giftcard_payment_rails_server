class AddMerchantIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :merchant_id, :integer
    add_index  :providers, :merchant_id
  end
end
