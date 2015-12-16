class AddFeaturesToAffiliates < ActiveRecord::Migration
  def change
    add_column :affiliates, :features, :string
  end
end
