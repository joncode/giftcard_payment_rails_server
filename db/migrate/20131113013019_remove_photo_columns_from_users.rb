class RemovePhotoColumnsFromUsers < ActiveRecord::Migration
  def up
        # MOVE PHOTO TO :iphone_photo
    us = User.unscoped
    us.each do |user|
        pic = user.get_photo
        if pic ==  "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
            user.iphone_photo = nil
        else
            user.iphone_photo = pic
        end
        user.save
    end

    remove_column :users, :fb_photo
    remove_column :users, :use_photo
    remove_column :users, :photo
    remove_column :users, :secure_image
  end

  def down
    add_column :users, :fb_photo,    :string
    add_column :users, :use_photo,   :string
    add_column :users, :photo,       :string
    add_column :users, :secure_image, :string
  end
end
