class DropOldTables < ActiveRecord::Migration
  def up
  	drop_table :providers
  	drop_table :mock_payables
  	drop_table :providers_socials
  	drop_table :providers_tags
  	drop_table :redeems
  	drop_table :orders


  end
end
