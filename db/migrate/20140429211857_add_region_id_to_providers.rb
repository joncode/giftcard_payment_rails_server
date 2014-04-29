class AddRegionIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :region_id, :integer
  end
end
