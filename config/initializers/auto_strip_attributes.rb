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
	set_filter max_length_char_vary: false do |value|
		value.respond_to?(:to_s) ? value.to_s[0..253] : value
	end
	filters_enabled[:squish] = true
end

# https://github.com/holli/auto_strip_attributes


# Default filters

# By default the following filters are defined (listed in the order of processing):

# :convert_non_breaking_spaces (disabled by default) - converts non-breaking spaces to normal spaces (Unicode U+00A0)
# :strip (enabled by default) - removes whitespaces from the beginning and the end of string
# :nullify (enabled by default) - replaces empty strings with nil
# :squish (disabled by default - ENABLED) - replaces extra whitespaces (including tabs) with one space
# :delete_whitespaces (disabled by default) - delete all whitespaces (including tabs)