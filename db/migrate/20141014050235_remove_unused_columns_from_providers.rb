class RemoveUnusedColumnsFromProviders < ActiveRecord::Migration
  def up
	remove_column :providers, :sd_location_id
	remove_column :providers, :address_2
	remove_column :providers, :foursquare_id
	remove_column :providers, :twitter
	remove_column :providers, :facebook
	remove_column :providers, :website
	remove_column :providers, :email
  end

  def down
	add_column 	  :providers, :sd_location_id, :integer
	add_column 	  :providers, :address_2, 		:string
	add_column 	  :providers, :foursquare_id, 	:string
	add_column 	  :providers, :twitter, 	:string
	add_column 	  :providers, :facebook, 	:string
	add_column 	  :providers, :website, 	:string
	add_column 	  :providers, :email, 		:string
  end
end