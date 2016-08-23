include ShortenPhotoUrlHelper

AutoStripAttributes::Config.setup do
	set_filter unshorten_photo_url: false do |value|
		unshorten_photo_url value
	end
	filters_enabled[:squish] = true
end

# https://github.com/holli/auto_strip_attributes