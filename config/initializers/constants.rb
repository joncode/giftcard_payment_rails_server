SERVICE_NAME = "ItsOnMe"


if Rails.env.production?
    PAGE_NAME        = SERVICE_NAME
    TEST_URL         = "http://www.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtools.herokuapp.com"
    PUBLIC_URL       = "http://www.itson.me"
    PUBLIC_URL_AT    = "http://admin.itson.me"
    PUBLIC_URL_MT    = "http://merchant.itson.me"
    SOCIAL_PROXY_URL = "http://m.itson.me/api"
    HELP_CONTACT     = { "email" => "rachel.wenman@itson.me", "name" => "Rachel"}
    ADMIN_NOTICE_CONTACT = ["david.leibner@itson.me", "rachel.wenman@itson.me"]
elsif Rails.env.staging?
    PAGE_NAME        = "#{SERVICE_NAME} (staging)"
    TEST_URL         = "http://qa.drinkboardapp.com"
    MERCHANT_URL     = "http://merchtoolsdev.herokuapp.com"
    PUBLIC_URL       = "http://qa.itson.me"
    PUBLIC_URL_AT    = "http://qaadmin.itson.me"
    PUBLIC_URL_MT    = "http://qamerchant.itson.me"
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    HELP_CONTACT     = { "email" => "support@itson.me", "name" => "Craig"}
    ADMIN_NOTICE_CONTACT = ["support@itson.me"]
else
    PAGE_NAME        = "Dev #{SERVICE_NAME} (local)"
    TEST_URL         = "http://0.0.0.0:3001"
    MERCHANT_URL     = "http://0.0.0.0:3000"
    PUBLIC_URL       = "http://0.0.0.0:3001"
    PUBLIC_URL_AT    = "http://0.0.0.0:3002"
    PUBLIC_URL_MT    = "http://0.0.0.0:3000"
    SOCIAL_PROXY_URL = "http://qam.itson.me/api"
    HELP_CONTACT     = { "email" => "zo@itson.me", "name" => "Craig"}
    ADMIN_NOTICE_CONTACT = ["zo@itson.me"]
end

SLICKTEXT_PUBLIC  = "pub_fa0f3e7f9ddaeefc89ca3d40d93c2472"

DEFAULT_RECEIPT_IMG_URL = "d|v1420767965/default_receipt_photo_pymjmb.png"

AT_EMAIL       = "@itson.me"
SUPPORT_EMAIL  = "support#{AT_EMAIL}"
INFO_EMAIL     = "info#{AT_EMAIL}"
NO_REPLY_EMAIL = "no-reply#{AT_EMAIL}"
FEEDBACK_EMAIL = "feedback#{AT_EMAIL}"

NUMBER_ID = 649387

VERSION_NUMBER  = "1.3.7"
VERSION_UPDATED = "2/11/14"


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

Time::DATE_FORMATS[:merchant]        = "%I:%M %p"
Time::DATE_FORMATS[:merchant_date]   = "%b %e %I:%M %p"
Time::DATE_FORMATS[:only_date]       = "%b %e"

#GIFT_CAT = { 0 => "NULL", 100 => "Admin", 101 => "AdminRegift", 150 => "AdminCampaign", 151 => "AdminCampaignRegift", 200 => "Merchant", 201 => "MerchantRegift", 250 => "MerchantCampaign", 251 => "MerchantCampaignRegift", 300 => "Standard", 301 => "StandardRegift" }
GIFT_CAT = { 100 => "Admin", 101 => "AdmRegift", 107 => "AdmBoom", 150 => "AdmCamp", 151 => "AdmCampRegift", 157 => "AdmCampBoom", 200 => "Merchant", 201 => "MerchantRegift", 207 => "MerchantBoom", 250 => "MerchCamp", 251 => "MerchCampRegift", 257 => "MerchCampBoom", 300 => "Standard", 301 => "StndRegift", 307 => "StndBoom" }

REDEMPTION_HSH = {1 => "V1" , 2 => "V2",  3 => "Pos" }

CITY_LIST =  [{"name"=>"Las Vegas", "state"=>"Nevada", "city_id"=>1, "photo"=>"d|v1378747548/las_vegas_xzqlvz.jpg"},
 {"name"=>"San Diego", "state"=>"California", "city_id"=>3, "photo"=>"d|v1378747548/san_diego_oj3a5w.jpg"},
 {"name"=>"San Francisco", "state"=>"California", "city_id"=>4, "photo"=>"d|v1378747548/san_francisco_hv2bsc.jpg"},
 {"name"=>"Santa Barbara", "state"=>"California", "city_id"=>5, "photo"=>"d|v1393292171/santa_barbara_lqln3n.jpg"},
  {"name"=>"Long Beach", "state"=>"California", "city_id"=>7, "photo"=>"d|v1416615199/LongBeach_jtrb0s.jpg"},
  {"name"=>"Newport Beach", "state"=>"California", "city_id"=>8, "photo"=>"d|v1416615229/newportbeach_bwwmrq.jpg"},
  {"name"=>"Orange County", "state"=>"California", "city_id"=>11, "photo"=>"d|v1419883807/orange_country_pgbmsg.jpg"},
  {"name"=>"New York", "state"=>"New York", "city_id"=>2, "photo"=>"d|v1393292178/new_york_iriwla.jpg"},
  {"name"=>"Elkhart Lake", "state"=>"Wisconsin", "city_id"=>9, "photo"=>"d|v1418237673/elkheart_tplhzq.jpg"},
 {"name"=>"COCHON 555 US TOUR", "state"=>"Nationwide", "city_id"=>10, "photo"=>"d|v1417972995/cochon_hr8ixy.png"}]






