namespace :db do


# 1. put the photo.url in fb_photo  (- nil the default blank get_photo)
    task user_image_url_to_fb_photo: :environment do
	  	User.all.each do |user|
	  		image_url = case user.use_photo
			when "cw"
				user.photo.url
			when "ios"
				user.iphone_photo
			when "fb"
				user.fb_photo
			else
				if user.photo.blank?
					nil
				else
					user.photo.url
				end
			end
	  		user.fb_photo = image_url
	  		user.save
	  	end
	end

# 2. remove the uploaders and comment them out 

# 3.  move fb+phtoto back to photo
	task fb_photo_to_photo: :environment do
		User.all.each do |user|
			user.photo = photo.fb_photo
		end
	end

# 4. delete fb_photo, photo_cache, secure_image (- first check that secure image is no longer used )
  # note: User 31 is the only one with using secure_image
  # rails g migration remove_image_columns_from_providers
  # 
  # def change
  #   remove_column :providers, :fb_photo, :string
  #   remove_column :providers, :photo_cache, :string
  #   remove_column :providers, :secure_image, :string
  # end

# re-write get_photo

	# def get_photo
	# 	case self.use_photo
	# 	when "cw"
	# 		self.photo
	# 	when "ios"
	# 		self.iphone_photo
	# 	when "fb"
	# 		self.photo
	# 	else
	# 		if self.photo.blank?
	# 			"http://res.cloudinary.com/htaaxtzcv/image/upload/v1361898825/ezsucdxfcc7iwrztkags.jpg"
	# 		else
	# 			self.photo
	# 		end
	# 	end
	# end

end