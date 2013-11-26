class RemovePhotoColumnsFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :fb_photo,    :string
    remove_column :users, :use_photo,   :string
    remove_column :users, :photo,       :string
    remove_column :users, :secure_image, :string
  end
end
