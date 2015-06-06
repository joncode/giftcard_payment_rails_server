class AddActiveToAffiliates < ActiveRecord::Migration
  def change
  	add_column :affiliates, :active, :boolean, default: true
  end
end
