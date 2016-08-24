include ShortenPhotoUrlHelper

AutoStripAttributes::Config.setup do
	set_filter unshorten_photo_url: false do |value|
		unshorten_photo_url value
	end
	set_filter downcase: false do |value|
		value.downcase
	end
	set_filter letter_numbers: false do |value|
		value.gsub(/[^a-zA-Z0-9]/, '')
	end
	filters_enabled[:squish] = true
end

# https://github.com/holli/auto_strip_attributes