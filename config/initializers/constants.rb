SERVICE_NAME = "ItsOnMe"

if Rails.env.production?
    PAGE_NAME        = SERVICE_NAME
    TEST_URL         = "http://www.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtools.herokuapp.com"
    PUBLIC_URL       = "http://www.itson.me"
    CLEAR_CACHE      = 'https://www.itson.me'
    APIURL           = "https://api.itson.me/web/v3"
    PUBLIC_URL_AT    = "http://admin.itson.me"
    PUBLIC_URL_MT    = "http://merchant.itson.me"
    PUBLIC_URL_PT    = "http://partner.itson.me"
    IOS_CLIENT_ID = 5
    IOS_15 = 160
    ANDROID_CLIENT_ID = 4
    ANDROID_15 = 161
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://m.itson.me/api"
    API_URL          = "https://api.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "david.leibner@itson.me", "name" => "David"}
    HELP_CONTACT_ARY     = [{ "email" => "david.leibner@itson.me", "name" => "David"}, { "email" => "support@itson.me", "name" => "Craig"}]

    ADMIN_NOTICE_CONTACT = ["david.leibner@itson.me", "support@itson.me"]
elsif Rails.env.staging?
    PAGE_NAME        = "#{SERVICE_NAME} (staging)"
    TEST_URL         = "http://qa.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtoolsdev.herokuapp.com"
    CLEAR_CACHE      = 'https://qa.itson.me'
    APIURL           = "https://qaapi.itson.me/web/v3"
    PUBLIC_URL       = "http://qa.itson.me"
    PUBLIC_URL_AT    = "http://qaadmin.itson.me"
    PUBLIC_URL_MT    = "http://qamerchant.itson.me"
    PUBLIC_URL_PT    = "http://qapartner.itson.me"
    IOS_CLIENT_ID = 8
    IOS_15 = 30
    ANDROID_CLIENT_ID = 6
    ANDROID_15 = 29
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    API_URL          = "https://qaapi.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "support@itson.me", "name" => "Craig"}
    HELP_CONTACT_ARY     = [{ "email" => "support@itson.me", "name" => "Craig"},{ "email" => "jon.gutwillig@itson.me", "name" => "Jon"}]

    ADMIN_NOTICE_CONTACT = ["support@itson.me"]
else
    PAGE_NAME        = "Dev #{SERVICE_NAME} (local)"
    TEST_URL         = "http://0.0.0.0:3001"
    MERCHANT_URL     = "http://0.0.0.0:3000"
    CLEAR_CACHE      = 'http://0.0.0.0:3001'
    APIURL           = "https://api.itson.me/web/v3"
    PUBLIC_URL       = "http://0.0.0.0:3001"
    PUBLIC_URL_AT    = "http://0.0.0.0:3002"
    PUBLIC_URL_MT    = "http://merchant.happyer.dev/"
    PUBLIC_URL_PT    = "http://partner.happyer.dev/"
    IOS_CLIENT_ID = 8
    IOS_15 = 30
    ANDROID_CLIENT_ID = 4
    ANDROID_15 = 161
    WBG_CLIENT_ID = 1
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    API_URL          = "https://qaapi.itson.me/web/v3"
    HELP_CONTACT     = { "email" => "jon.gutwillig@itson.me", "name" => "Jon"}
    HELP_CONTACT_ARY     = [{ "email" => "jon.gutwillig@itson.me", "name" => "Jon"}]

    ADMIN_NOTICE_CONTACT = ["support@itson.me"]
end

GOLFNOW_COM = 331
GOLFADVISOR_COM = 13326
GOLFCOURSE_WEBSITE = 74
GOLFFACEBOOK_TAB = 62
SINGLEPLATFORM_ID = 86

QRURL = "https://2.zap.pe"
DEVELOPER_TEXT = '2152000475'
HELP_DESK_URL = 'https://itsonmeapp.zendesk.com/hc/en-us/categories/200160205-App-Users'

if Rails.env.production?
    FB_NAMESPACE = 'itsonme'
else
    FB_NAMESPACE = 'itsonme_test'
end
FACEBOOK_OPS_PAGE_LIMIT = 1000

SLICKTEXT_PUBLIC  = "pub_fa0f3e7f9ddaeefc89ca3d40d93c2472"

DEFAULT_RECEIPT_IMG_URL = "https://res.cloudinary.com/drinkboard/image/upload/v1420767965/default_receipt_photo_pymjmb.png"

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

VERSION_NUMBER  = "2.0.0"
VERSION_UPDATED = "10/11/16"

TIME_ZONES = {0 => "Pacific Time (US & Canada)", 1 => "Mountain Time (US & Canada)", 2 => "Central Time (US & Canada)", 3 => "Eastern Time (US & Canada)"}


if Rails.env.test?
    CSV_LIMIT   = 10
else
    CSV_LIMIT   = 5000
end

BLANK_AVATAR_URL = "https://res.cloudinary.com/drinkboard/image/upload/v1398470766/avatar_blank_cvblvd.png"
GENERIC_RECEIVER_NAME = "Enjoy!"

VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
VALID_PHONE_REGEX = /1?\s*\W?\s*([2-9][0-8][0-9])\s*\W?\s*([2-9][0-9]{2})\s*\W?\s*([0-9]{4})(\se?x?t?(\d*))?/
# this regex for phone does not work for '(210)-' unusual but possible mistake

# STATUSES
CLEARANCE_HASH       = {'Staff' => 0, 'Manager' => 50 , "Admin" => 90 }
CLEARANCE_LEVELS     = CLEARANCE_HASH.keys

Time::DATE_FORMATS[:merchant]        = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
Time::DATE_FORMATS[:only_date]       = "%b %e"
Time::DATE_FORMATS[:url_date]       = "%Y-%m-%d"

#GIFT_CAT = { 0 => "NULL", 100 => "Admin", 101 => "AdminRegift", 150 => "AdminCampaign", 151 => "AdminCampaignRegift", 200 => "Merchant", 201 => "MerchantRegift", 250 => "MerchantCampaign", 251 => "MerchantCampaignRegift", 300 => "Standard", 301 => "StandardRegift" }
GIFT_CAT = { 100 => "Admin", 101 => "AdmRegift", 107 => "AdmBoom", 150 => "AdmCamp", 151 => "AdmCampRegift", 157 => "AdmCampBoom", 200 => "Merchant", 201 => "MerchantRegift", 207 => "MerchantBoom", 250 => "MerchCamp", 251 => "MerchCampRegift", 257 => "MerchCampBoom", 300 => "Standard", 301 => "StndRegift", 307 => "StndBoom" }

REDEMPTION_HSH = {1 => "V1" , 2 => "V2",  3 => "Pos", 4 => 'Paper' }

# LOCATION DATA

CANADIAN_HSH = {
    "AB" => "Alberta",
    "BC" => "British Columbia",
    "MB" => "Manitoba",
    "NB" => "New Burnswick",
    "NL" => "Newfoundland and Labrador",
    "NS" => "Nova Scotia",
    "NT" => "Northwest Territories",
    "NU" => "Nunavut",
    "ON" => "Ontario",
    "PE" => "Prince Edward Island",
    "QC" => "Quebec",
    "SK" => "Saskatchewan",
    "YT" => "Yukon"
}

USA_HSH = {
    "AL" => "Alabama",
    "AK" => "Alaska",
    "AZ" => "Arizona",
    "AR" => "Arkansas",
    "CA" => "California",
    "CO" => "Colorado",
    "CT" => "Connecticut",
    "DE" => "Delaware",
    "DC" => "District of Columbia",
    "FL" => "Florida",
    "GA" => "Georgia",
    "HI" => "Hawaii",
    "ID" => "Idaho",
    "IL" => "Illinois",
    "IN" => "Indiana",
    "IA" => "Iowa",
    "KS" => "Kansas",
    "KY" => "Kentucky",
    "LA" => "Louisiana",
    "ME" => "Maine",
    "MD" => "Maryland",
    "MA" => "Massachusetts",
    "MI" => "Michigan",
    "MN" => "Minnesota",
    "MS" => "Mississippi",
    "MO" => "Missouri",
    "MT" => "Montana",
    "NE" => "Nebraska",
    "NV" => "Nevada",
    "NH" => "New Hampshire",
    "NJ" => "New Jersey",
    "NM" => "New Mexico",
    "NY" => "New York",
    "NC" => "North Carolina",
    "ND" => "North Dakota",
    "OH" => "Ohio",
    "OK" => "Oklahoma",
    "OR" => "Oregon",
    "PA" => "Pennsylvania",
    "RI" => "Rhode Island",
    "SC" => "South Carolina",
    "SD" => "South Dakota",
    "TN" => "Tennessee",
    "TX" => "Texas",
    "UT" => "Utah",
    "VT" => "Vermont",
    "VA" => "Virginia",
    "WA" => "Washington",
    "WV" => "West Virginia",
    "WI" => "Wisconsin",
    "WY" => "Wyoming"
}


