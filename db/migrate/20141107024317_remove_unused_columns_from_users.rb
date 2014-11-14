class RemoveUnusedColumnsFromUsers < ActiveRecord::Migration
  def up
	remove_column :users, :credit_number
	remove_column :users, :facebook_access_token
	remove_column :users, :foursquare_id
	remove_column :users, :facebook_expiry
	remove_column :users, :foursquare_access_token
	remove_column :users, :facebook_auth_checkin
	remove_column :users, :admin
	remove_column :users, :server_code
  end

  def down
	add_column 	  :users, :credit_number, 				:string
	add_column 	  :users, :facebook_access_token, 		:string
	add_column 	  :users, :foursquare_id, 				:string
	add_column 	  :users, :facebook_expiry, 			:datetime
	add_column 	  :users, :foursquare_access_token, 	:string
	add_column 	  :users, :facebook_auth_checkin, 		:boolean
	add_column 	  :users, :admin, 						:boolean
	add_column 	  :users, :server_code, 				:string
  end
end
