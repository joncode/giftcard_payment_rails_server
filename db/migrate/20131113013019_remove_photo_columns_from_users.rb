class RemovePhotoColumnsFromUsers < ActiveRecord::Migration
  def up
        # MOVE PHOTO TO :iphone_photo
    us = User.unscoped
    u2 = us.select {|u| u.get_photo != "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"}
    u3 = u2.select { |u| !u.get_photo.nil? }
    good = 0
    bad  = 0
    no_save = 0
    total = us.count
    us.each do |user|
        pic = user.get_photo_old
        if pic ==  "http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
            bad += 1
            user.iphone_photo = nil
        else
            good += 1
            user.iphone_photo = pic
        end
        unless user.save
            puts "user photo save error ! user = #{user.id}"
            no_save += 1
        end
    end

    puts "MOVE PHOTO FOR USERS"
    puts "Good = #{good}"
    puts "Bad  = #{bad}"
    puts "Total = #{total}"
    puts "No Saves = #{no_save}"
    tot = good + bad
    puts "Good + Bad = #{tot}"
    puts "Original Good = #{u3.count}"
    wrong = u3.count - good
    puts "WRONG = #{wrong} - if negative , its ok"
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
