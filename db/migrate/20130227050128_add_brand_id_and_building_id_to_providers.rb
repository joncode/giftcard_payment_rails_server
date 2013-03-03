class AddBrandIdAndBuildingIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :brand_id, :integer
    add_column :providers, :building_id, :integer
  end
end
