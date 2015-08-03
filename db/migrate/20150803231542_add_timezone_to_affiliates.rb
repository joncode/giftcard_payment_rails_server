class AddTimezoneToAffiliates < ActiveRecord::Migration
  def change
  	add_column :affiliates, :tz, :integer, default: 0
  end
end
