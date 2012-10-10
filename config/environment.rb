# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Drinkboard::Application.initialize!


# Cloudinary info here OR cloudinary.yml
CLOUDINARY_URL        = "cloudinary://524481758822216:BF2QigcKBvYJ8DCucCPqUsVcWvI@drinkboard"
CLOUDINARY_BASE_URL   = "http://res.cloudinary.com/drinkboard"
CLOUDINARY_IMAGE_URL  = "http://res.cloudinary.com/drinkboard/image/upload"	
CLOUDINARY_IMAGE2_URL = "http://res.cloudinary.com/htaaxtzcv/image/upload"	
CLOUDINARY_SECURE_URL = "https://d3jpl91pxevbkh.cloudfront.net/drinkboard"
CLOUDINARY_UPLOAD     = "http://api.cloudinary.com/v1_1/drinkboard/image/upload"
CLOUDINARY_GHOST_USER = "https://d3jpl91pxevbkh.cloudfront.net/drinkboard/image/upload/v1349221640/yzjd1hk2ljaycqknvtyg.png"

# AWS S3 folder info
BUCKET    = 'drinkboard'
THUMB     = 'drinkboard/thumb'
PORTRAIT  = 'drinkboard/portrait'



# http://res.cloudinary.com/drinkboard/image/upload/v1349148077/ezsucdxfcc7iwrztkags.png
# https://d3jpl91pxevbkh.cloudfront.net/drinkboard/image/upload/v1349221640/yzjd1hk2ljaycqknvtyg.png