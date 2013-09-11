if Rails.env.production?
    PAGE_NAME       = 'Drinkboard - Admin Tools'
    TEST_URL        = "http://www.drinkboardapp.com"
    MERCHANT_URL    = "http://merchtools.herokuapp.com"
    PUB_MERCH_URL   = "http://merchant.drinkboard.com"
    PUBLIC_URL      = "http://www.drinkboard.com"
elsif Rails.env.staging?
    PAGE_NAME       = 'QA Drinkboard - Admin Tools (staging)'
    TEST_URL        = "http://qa.drinkboardapp.com"
    MERCHANT_URL    = "http://merchtoolsdev.herokuapp.com"
    PUB_MERCH_URL   = "http://qamerchant.drinkboard.com"
    PUBLIC_URL      = "http://qa.drinkboard.com"
else
    PAGE_NAME       = 'Dev Drinkboard - Admin Tools (local)'
    TEST_URL        = "http://0.0.0.0:3001"
    MERCHANT_URL    = "http://0.0.0.0:3000"
    PUB_MERCH_URL   = "http://0.0.0.0:3000"
    PUBLIC_URL      = "http://0.0.0.0:3001"
end

NUMBER_ID = 649387

VERSION_NUMBER  = "1.0.0DBA"
VERSION_UPDATED = "9/1/13"

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
# this regex for phone does not work for '(210)-' unusual but possible mistake
BEVERAGE_CATEGORIES = ['signature', 'beer', 'wine', 'cocktail', 'shot']
GIFT_STATUS         = ['open', 'notified', 'redeemed', 'regifted', 'returned', 'incomplete']
PROOF_LEVELS        = ['zero', 'lite', 'normal', 'double']

# MANDRILL
ENV['MANDRILL_APIKEY'] =  'oUXP1PDOtP14RMgFytxdGw'

    # Subtle Data Constants
PIPE        = "%7C"
SD_ROOT     = "https://www.subtledata.com/API/M/1/?Q="
WEB_KEY     = "RlgrM1Uw"


BUTTONS = ["burger", "openlate", "bar", "club", "signature", "brunch", "steak", "martini", "wine", "beer", "cocktail", "dinig"]

Time::DATE_FORMATS[:merchant]        = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
Time::DATE_FORMATS[:only_date]       = "%b %e"

GENERAL_TOKEN = "1964f94b3e567a8a82b87f3ccbeb2174"
APP_GENERAL_TOKEN =  "0NFXbWsyP3Mj2Mroj_utsA"
