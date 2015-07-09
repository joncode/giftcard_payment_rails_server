class ProviderDataToMerchant < ActiveRecord::Migration
  def up
  	require('provider_to_merchant')
  	pm = ProviderToMerchant.new
  	pm.start
  end

  def down
  end
end
