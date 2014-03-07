if Rails.env.production?
    AUTH_GATEWAY = :production
else
    AUTH_GATEWAY = :sandbox
end

CATCH_PHRASE = if Rails.env.development? or Rails.env.test?
    "Theres no place like home"
else
    ENV['CATCH_PHRASE']
end

CCS_KEY = if Rails.env.development? or Rails.env.test?
    "Yes yes yes"
else
    ENV['CCS_KEY']
end

AUTHORIZE_API_LOGIN = if Rails.env.development? or Rails.env.test?
    '948bLpzeE8UY'
else
    ENV['AUTHORIZE_API_LOGIN']
end

AUTHORIZE_TRANSACTION_KEY = if Rails.env.development? or Rails.env.test?
    '7f7AZ66axeC386q7'
else
    ENV['AUTHORIZE_TRANSACTION_KEY']
end

MAILCHIMP_APIKEY = if Rails.env.development? or Rails.env.test?
    '925c032769638d199309b7c752c31700-us7'
else
    ENV['MAILCHIMP_APIKEY']
end

MANDRILL_APIKEY = if Rails.env.development? or Rails.env.test?
    'oUXP1PDOtP14RMgFytxdGw'
else
    ENV['MANDRILL_APIKEY']
end

MAILCHIMP_LIST_ID = if Rails.env.development? or Rails.env.test?
    'b29e278ebe'
else
    ENV['MAILCHIMP_LIST_ID']
end

GENERAL_TOKEN = if Rails.env.development? or Rails.env.test?
     "1964f94b3e567a8a82b87f3ccbeb2174"
else
    ENV['GENERAL_TOKEN']
end

WWW_TOKEN = if Rails.env.development? or Rails.env.test?
     "nj3tOdJOaZa-qFx0FhCLRQ"
else
    ENV['WWW_TOKEN']
end

APP_GENERAL_TOKEN = if Rails.env.development? or Rails.env.test?
     "0NFXbWsyP3Mj2Mroj_utsA"
else
    ENV['APP_GENERAL_TOKEN']
end

ANDROID_TOKEN = if Rails.env.development? or Rails.env.test?
     "e7f122d463e7ca786a150a33e21216a1"
else
    ENV['ANDROID_TOKEN']
end

SOCIAL_PROXY_TOKEN = if Rails.env.development? or Rails.env.test?
    "OYDvisC4qke6y5KPytkIBg"
else
    ENV['SOCIAL_PROXY_TOKEN']
end

SLICKTEXT_API_KEY = if Rails.env.development? or Rails.env.test?
    "OYDvisC4qke6y5KPytkIBg"
else
    ENV['SLICKTEXT_API_KEY']
end

