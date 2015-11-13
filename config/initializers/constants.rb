SERVICE_NAME = "ItsOnMe"


if Rails.env.production?
    PAGE_NAME        = SERVICE_NAME
    TEST_URL         = "http://www.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtools.herokuapp.com"
    PUBLIC_URL       = "http://www.itson.me"
    CLEAR_CACHE      = 'https://www.itson.me'
    PUBLIC_URL_AT    = "http://admin.itson.me"
    PUBLIC_URL_MT    = "http://merchant.itson.me"
    PUBLIC_URL_PT    = "http://partner.itson.me"
    IOS_CLIENT_ID = 5
    ANDROID_CLIENT_ID = 4
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://m.itson.me/api"
    API_URL          = "https://api.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "david.leibner@itson.me", "name" => "David"}
    HELP_CONTACT_ARY     = [{ "email" => "david.leibner@itson.me", "name" => "David"}]

    ADMIN_NOTICE_CONTACT = ["david.leibner@itson.me", "support@itson.me"]
elsif Rails.env.staging?
    PAGE_NAME        = "#{SERVICE_NAME} (staging)"
    TEST_URL         = "http://qa.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtoolsdev.herokuapp.com"
    CLEAR_CACHE      = 'https://qa.itson.me'
    PUBLIC_URL       = "http://qa.itson.me"
    PUBLIC_URL_AT    = "http://qaadmin.itson.me"
    PUBLIC_URL_MT    = "http://qamerchant.itson.me"
    PUBLIC_URL_PT    = "http://qapartner.itson.me"
    IOS_CLIENT_ID = 8
    ANDROID_CLIENT_ID = 6
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    API_URL          = "https://qaapi.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "support@itson.me", "name" => "Craig"}
    HELP_CONTACT_ARY     = [{ "email" => "support@itson.me", "name" => "Craig"}]

    ADMIN_NOTICE_CONTACT = ["support@itson.me"]
else
    PAGE_NAME        = "Dev #{SERVICE_NAME} (local)"
    TEST_URL         = "http://0.0.0.0:3001"
    MERCHANT_URL     = "http://0.0.0.0:3000"
    CLEAR_CACHE      = 'http://0.0.0.0:3001'
    PUBLIC_URL       = "http://0.0.0.0:3001"
    PUBLIC_URL_AT    = "http://0.0.0.0:3002"
    PUBLIC_URL_MT    = "http://merchant.happyer.dev/"
    PUBLIC_URL_PT    = "http://partner.happyer.dev/"
    IOS_CLIENT_ID = 5
    ANDROID_CLIENT_ID = 4
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    API_URL          = "https://qaapi.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "jon.gutwillig@itson.me", "name" => "Jon"}
    HELP_CONTACT_ARY     = [{ "email" => "jon.gutwillig@itson.me", "name" => "Jon"}]

    ADMIN_NOTICE_CONTACT = ["support@itson.me"]
end

SLICKTEXT_PUBLIC  = "pub_fa0f3e7f9ddaeefc89ca3d40d93c2472"

DEFAULT_RECEIPT_IMG_URL = "d|v1420767965/default_receipt_photo_pymjmb.png"

AT_EMAIL       = "@itson.me"
SUPPORT_EMAIL  = "support#{AT_EMAIL}"
INFO_EMAIL     = "info#{AT_EMAIL}"
NO_REPLY_EMAIL = "no-reply#{AT_EMAIL}"
FEEDBACK_EMAIL = "feedback#{AT_EMAIL}"

NUMBER_ID = 649387

# delete orders model
# delete redeem model
# delete app_controller & iphone_controller
# get rid of web/v1 & web/v2


#  make migrations to delete mt_user, at_user, user ->  :remember_token
#  make migration to delete mt_user, at_user, user ->  :password_digest
#  make migration to remove { affiliate_id - password_digest => mt_user }

VERSION_NUMBER  = "1.6.3.2"
VERSION_UPDATED = "7/23/15"



if Rails.env.test?
    CSV_LIMIT   = 10
else
    CSV_LIMIT   = 5000
end

BLANK_AVATAR_URL = "http://res.cloudinary.com/drinkboard/image/upload/v1398470766/avatar_blank_cvblvd.png"
GENERIC_RECEIVER_NAME = "ItsOnMe User"

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
# this regex for phone does not work for '(210)-' unusual but possible mistake

# STATUSES
CLEARANCE_HASH       = {'Staff' => 0, 'Manager' => 50 , "Admin" => 90 }
CLEARANCE_LEVELS     = CLEARANCE_HASH.keys

Time::DATE_FORMATS[:merchant]        = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
Time::DATE_FORMATS[:only_date]       = "%b %e"

#GIFT_CAT = { 0 => "NULL", 100 => "Admin", 101 => "AdminRegift", 150 => "AdminCampaign", 151 => "AdminCampaignRegift", 200 => "Merchant", 201 => "MerchantRegift", 250 => "MerchantCampaign", 251 => "MerchantCampaignRegift", 300 => "Standard", 301 => "StandardRegift" }
GIFT_CAT = { 100 => "Admin", 101 => "AdmRegift", 107 => "AdmBoom", 150 => "AdmCamp", 151 => "AdmCampRegift", 157 => "AdmCampBoom", 200 => "Merchant", 201 => "MerchantRegift", 207 => "MerchantBoom", 250 => "MerchCamp", 251 => "MerchCampRegift", 257 => "MerchCampBoom", 300 => "Standard", 301 => "StndRegift", 307 => "StndBoom" }

REDEMPTION_HSH = {1 => "V1" , 2 => "V2",  3 => "Pos" }




