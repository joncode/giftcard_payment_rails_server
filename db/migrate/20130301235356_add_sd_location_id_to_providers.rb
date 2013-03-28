class AddSdLocationIdToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :sd_location_id, :integer
  end
end
