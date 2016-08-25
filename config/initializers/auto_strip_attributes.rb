include ShortenPhotoUrlHelper

AutoStripAttributes::Config.setup do
	set_filter unshorten_photo_url: false do |value|
		unshorten_photo_url value
	end
	set_filter downcase: false do |value|
		value.respond_to?(:downcase) ? value.downcase : value
	end
	set_filter letter_numbers: false do |value|
		value.respond_to?(:gsub) ? value.gsub(/[^a-zA-Z0-9]/, '') : value
	end
	filters_enabled[:squish] = true
end

# https://github.com/holli/auto_strip_attributes