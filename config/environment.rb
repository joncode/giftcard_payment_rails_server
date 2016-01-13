# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Drinkboard::Application.initialize!


# Cloudinary info here OR cloudinary.yml
CLOUDINARY_URL        = "cloudinary://524481758822216:BF2QigcKBvYJ8DCucCPqUsVcWvI@drinkboard"
CLOUDINARY_BASE_URL   = "https://res.cloudinary.com/drinkboard"
CLOUDINARY_IMAGE_URL  = "https://res.cloudinary.com/drinkboard/image/upload/"
if Rails.env.staging?
    CLOUDINARY_IMAGE2_URL = "https://res.cloudinary.com/hsdbwezkg/image/upload/"
elsif Rails.env.production?
    CLOUDINARY_IMAGE2_URL = "https://res.cloudinary.com/htaaxtzcv/image/upload/"
else
    CLOUDINARY_IMAGE2_URL = "https://res.cloudinary.com/drinkboard/image/upload/"
end
CLOUDINARY_SECURE_URL = "https://d3jpl91pxevbkh.cloudfront.net/drinkboard"
CLOUDINARY_UPLOAD     = "https://api.cloudinary.com/v1_1/drinkboard/image/upload"
CLOUDINARY_GHOST_USER = "https://d3jpl91pxevbkh.cloudfront.net/drinkboard/image/upload/v1349221640/yzjd1hk2ljaycqknvtyg.png"

MERCHANT_DEFAULT_IMG = "https://res.cloudinary.com/drinkboard/image/upload/v1349150293/upqygknnlerbevz4jpnw.png"


# http://res.cloudinary.com/drinkboard/image/upload/v1349148077/ezsucdxfcc7iwrztkags.png
# https://d3jpl91pxevbkh.cloudfront.net/drinkboard/image/upload/v1349221640/yzjd1hk2ljaycqknvtyg.png
