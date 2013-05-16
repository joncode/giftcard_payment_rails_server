# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Drinkboard::Application.config.secret_token = '80cb854c626de01bc9fce3ffdbb7c83961ca54311520874da313b8bb98eeeb3e343843187d0b743604ff43963bb43d0f62f4e13265d3776a9cae2912eb1a2687'

PAGE_NAME = 'Drinkboard Tools'
VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
# this regex for phone does not work for '(210)-' unusual but possible mistake
BEVERAGE_CATEGORIES = ['signature', 'beer', 'wine', 'cocktail', 'shot']
GIFT_STATUS   		= ['open', 'notified', 'redeemed', 'regifted', 'returned', 'incomplete']
PROOF_LEVELS  		= ['zero', 'lite', 'normal', 'double']

	# Subtle Data Constants
PIPE        = "%7C"
SD_ROOT     = "https://www.subtledata.com/API/M/1/?Q="
WEB_KEY     = "RlgrM1Uw"

if Rails.env.production?
	TEST_URL = "http://drinkboard.herokuapp.com"
elsif Rails.env.stage?
    TEST_URL = "http://dbappdev.herokuapp.com"
else
	TEST_URL = "http://0.0.0.0:3000"
end

if Rails.env.production?
    MERCHANT_URL = "http://happy2.herokuapp.com"
elsif Rails.env.stage?
    MERCHANT_URL = "http://happy2dev.herokuapp.com"
else
    MERCHANT_URL = "http://0.0.0.0:3000"
end



BUTTONS = ["burger", "openlate", "bar", "club", "signature", "brunch", "steak", "martini", "wine", "beer", "cocktail", "dinig"]

Time::DATE_FORMATS[:merchant] = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
