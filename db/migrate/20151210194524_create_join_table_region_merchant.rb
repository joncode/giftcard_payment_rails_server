class CreateJoinTableRegionMerchant < ActiveRecord::Migration
  def change
    create_join_table :regions, :merchants do |t|
      t.index :region_id
    end
  end
end
