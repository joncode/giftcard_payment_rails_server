namespace :db do

    task user_image_url_to_fb_photo: :environment do
	  	User.all.each do |user|
	  		image_url = 
			case user.use_photo
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

    task provider_image_url_to_photo_cache: :environment do
	  	Provider.all.each do |provider|
			image_url =
			if image.blank?
				if photo.blank?
					nil
				else
					photo.url
				end
			else
				image
			end
			provider.photo_cache = image_url
			provider.save
	end
end