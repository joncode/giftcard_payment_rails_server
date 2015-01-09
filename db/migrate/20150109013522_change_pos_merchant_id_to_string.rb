class ChangePosMerchantIdToString < ActiveRecord::Migration
  def up
  	change_column :providers, :pos_merchant_id, :string, default: nil
   	change_column :merchants, :pos_merchant_id, :string, default: nil
  end

  def down
  	change_column :providers, :pos_merchant_id, 'integer USING CAST(pos_merchant_id AS integer)'
   	change_column :merchants, :pos_merchant_id, 'integer USING CAST(pos_merchant_id AS integer)'
  end
end
