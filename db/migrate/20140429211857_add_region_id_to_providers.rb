class AddRegionIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :region_id, :integer

    add_index :providers, :region_id
  end
end
