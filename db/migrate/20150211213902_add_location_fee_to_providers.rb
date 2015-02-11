class AddLocationFeeToProviders < ActiveRecord::Migration
  def change
    add_column :providers, :location_fee, :integer, default: 0
  end
end
