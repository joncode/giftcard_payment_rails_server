class ChangeColumnDefaultOnRateOnMerchants < ActiveRecord::Migration
  def change
  	change_column_default(:merchants, :rate, 95.0)
  end
end
