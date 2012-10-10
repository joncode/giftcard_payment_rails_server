class AddNewPhotoUrlsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :iphone_photo, 	:string
    add_column :users, :fb_photo, 		:string
    add_column :users, :use_photo, 		:string
  end
end
