SERVICE_NAME = "ItsOnMe"


if Rails.env.production?
    PAGE_NAME       = SERVICE_NAME
    TEST_URL        = "http://www.drinkboardapp.com"
    MERCHANT_URL    = "http://merchtools.herokuapp.com"
    PUB_MERCH_URL   = "http://merchant.itson.me"
    PUBLIC_URL      = "http://www.itson.me"
    SOCIAL_PROXY_URL = "http://m.itson.me/api"
elsif Rails.env.staging?
    PAGE_NAME       = "#{SERVICE_NAME} (staging)"
    TEST_URL        = "http://qa.drinkboardapp.com"
    MERCHANT_URL    = "http://merchtoolsdev.herokuapp.com"
    PUB_MERCH_URL   = "http://qamerchant.itson.me"
    PUBLIC_URL      = "http://qa.itson.me"
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
else
    PAGE_NAME       = "Dev #{SERVICE_NAME} (local)"
    TEST_URL        = "http://0.0.0.0:3001"
    MERCHANT_URL    = "http://0.0.0.0:3000"
    PUB_MERCH_URL   = "http://0.0.0.0:3000"
    PUBLIC_URL      = "http://0.0.0.0:3001"
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
end


SLICKTEXT_PUBLIC  = "pub_fa0f3e7f9ddaeefc89ca3d40d93c2472"
SLICKTEXT_PRIVATE =  "0cc8841e131a2ecdc690a4d2e7b5a676255e26a8"



AT_EMAIL       = "@itson.me"
SUPPORT_EMAIL  = "support#{AT_EMAIL}"
INFO_EMAIL     = "info#{AT_EMAIL}"
NO_REPLY_EMAIL = "no-reply#{AT_EMAIL}"
FEEDBACK_EMAIL = "feedback#{AT_EMAIL}"

NUMBER_ID = 649387

VERSION_NUMBER  = "1.2.2.2"
VERSION_UPDATED = "3/11/14"

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
# this regex for phone does not work for '(210)-' unusual but possible mistake

Time::DATE_FORMATS[:merchant]        = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
Time::DATE_FORMATS[:only_date]       = "%b %e"

GIFT_CAT = { 0 => "User", 100 => "Regift", 200 => "Promo-Merchant", 210 => "Promo-Admin", 300 => "Campaign" }

