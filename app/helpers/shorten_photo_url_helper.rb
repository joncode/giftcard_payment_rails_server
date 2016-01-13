module ShortenPhotoUrlHelper

    def shorten_photo_url photo_url
        # if photo_url.kind_of?(String) && photo_url.include?("http://res.cloudinary.com/drinkboard/image/upload/")
        #     photo_url.gsub!("http://res.cloudinary.com/drinkboard/image/upload/", "d|")
        # end
        return photo_url
    end

    def unshorten_photo_url photo_url
        if photo_url.kind_of?(String) && photo_url.include?("d|")
            photo_url.gsub!("d|", "https://res.cloudinary.com/drinkboard/image/upload/")
        end
        return photo_url
    end

end