class AddPosDirectToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :pos_direct, :boolean, default: false
  end
end
