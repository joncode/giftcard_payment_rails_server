local_env = (Rails.env.development? || Rails.env.test?)

if Rails.env.production?
    AUTH_GATEWAY = :production
else
    AUTH_GATEWAY = :sandbox
end

APP_GENERAL_TOKEN = if local_env
     "0NFXbWsyP3Mj2Mroj_utsA"
else
    ENV['APP_GENERAL_TOKEN']
end

ANDROID_TOKEN = if local_env
     "e7f122d463e7ca786a150a33e21216a1"
else
    ENV['ANDROID_TOKEN']
end

AUTHORIZE_API_LOGIN = if local_env
    '948bLpzeE8UY'
else
    ENV['AUTHORIZE_API_LOGIN']
end

AUTHORIZE_TRANSACTION_KEY = if local_env
    '7f7AZ66axeC386q7'
else
    ENV['AUTHORIZE_TRANSACTION_KEY']
end

AUTHORIZE_MOBILE_DEVICE = if local_env
    '42741F4C-3C79-4C57-BF12-0591BFBB7956'
else
    ENV['AUTHORIZE_MOBILE_DEVICE']
end

if Rails.env.production?
    ActiveMerchant::Billing::Base.mode = :live
else
    ActiveMerchant::Billing::Base.mode = :test
end

FIRST_DATA_LOGIN_CAD = if local_env
    'SC9794-68'
else
    ENV['FIRST_DATA_LOGIN_CAD']
end

FIRST_DATA_PASSWORD_CAD = if local_env
    '9inAG7jSLjWn5WbKnDEJFyU4I95SOnPV'
else
    ENV['FIRST_DATA_PASSWORD_CAD']
end

CATCH_PHRASE = if local_env
    "Theres no place like home"
else
    ENV['CATCH_PHRASE']
end

CCS_KEY = if local_env
    "Yes yes yes"
else
    ENV['CCS_KEY']
end

CLOVER_TOKEN = if local_env
    "BVHA4jduazMQWpZ6lBooSA"
else
    ENV['CLOVER_TOKEN']
end

FACEBOOK_APP_ID = if local_env
    '1010660852318410'
else
    ENV['FACEBOOK_APP_ID']
end

FACEBOOK_APP_SECRET = if local_env
    '4a04ff8b8f97e0830089e1953ebbfdfb'
else
    ENV['FACEBOOK_APP_SECRET']
end

GOLFNOW_TOKEN = if local_env
    'G4PWlKoalSdFGJ5q5FbScw'
else
    ENV['GOLFNOW_TOKEN']
end

GCM_API_KEY = if local_env
    'AIzaSyA55nK5a30YQ51L3h1SSZbLlUNZC_GkheQ'
else
    ENV['GCM_API_KEY']
end

GENERAL_TOKEN = if local_env
     "1964f94b3e567a8a82b87f3ccbeb2174"
else
    ENV['GENERAL_TOKEN']
end

MAILCHIMP_APIKEY = if local_env
    '925c032769638d199309b7c752c31700-us7'
else
    ENV['MAILCHIMP_APIKEY']
end

MAILCHIMP_LIST_ID = if local_env
    'b29e278ebe'
else
    ENV['MAILCHIMP_LIST_ID']
end
# MANDRILL is located in config/initializers/mandrill.rb

NEXT_GEN_USER = if local_env
    'jfwwejfkslopwe'
else
    ENV['NEXT_GEN_USER']
end

NEXT_GEN_PASS = if local_env
    'hY9ek8Kkawpo2qQ8hE52l_qe8I'
else
    ENV['NEXT_GEN_PASS']
end

POSITRONICS_API_KEY = if local_env
    '203d714b6a3642379ce7ccbabe4e9926'
else
    ENV['POSITRONICS_API_KEY']
end

POSITRONICS_API_URL = "https://api.omnivore.io/0.1"

REDBULL_TOKEN = if local_env
     "O0LgUixWOE7Dec1Y_INA6Q"
else
    ENV['REDBULL_TOKEN']
end

RESQUE_AUTH = if local_env
    "Dboard77"
else
    ENV['RESQUE_AUTH']
end

SOCIAL_PROXY_TOKEN = if local_env
    "OYDvisC4qke6y5KPytkIBg"
else
    ENV['SOCIAL_PROXY_TOKEN']
end

SLICKTEXT_PRIVATE =  if local_env
    "0cc8841e131a2ecdc690a4d2e7b5a676255e26a8"
else
    ENV['SLICKTEXT_PRIVATE']
end

STRIPE_SECRET = if local_env
    'sk_test_UMvfuiV9aOOdq0H0xUeJWT3m'
else
    ENV["STRIPE_SECRET"]
end

TWILIO_ACCOUNT_SID = if local_env
    "ACbb70b5328755e8444166bbc82babdcb9"
else
    ENV['TWILIO_ACCOUNT_SID']
end

TWILIO_AUTH_TOKEN = if local_env
    "1ffccabdc95b0669400062f1a700a8cf"
else
    ENV['TWILIO_AUTH_TOKEN']
end

TWILIO_PHONE_NUMBER = if local_env
    "13107364884"
else
    ENV['TWILIO_PHONE_NUMBER'].gsub('+', '')
end

include ActionView::Helpers::NumberHelper
if TWILIO_PHONE_NUMBER[0] == '1'
    TWILIO_QUICK_NUM = number_to_phone(TWILIO_PHONE_NUMBER[1 .. -1], delimiter: "-")
else
    TWILIO_QUICK_NUM = number_to_phone(TWILIO_PHONE_NUMBER, delimiter: "-")
end

WWW_TOKEN = if local_env
     "nj3tOdJOaZa-qFx0FhCLRQ"
else
    ENV['WWW_TOKEN']
end

ZAPPER_API_URL = if local_env
    'https://zapqa.zapzapadmin.com/zappersandbox/api'
else
    ENV['ZAPPER_API_URL']
end

ZAPPER_API_KEY = if local_env
    "CFAEDF21-296B-4CF1-B9F0-79AC9F09911C"
else
    ENV["ZAPPER_API_KEY"]
end










