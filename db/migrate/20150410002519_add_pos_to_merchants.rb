class AddPosToMerchants < ActiveRecord::Migration
  def change
  	add_column :merchants, :pos_sys, :string
  end
end
