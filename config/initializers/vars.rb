if Rails.env.production?
    AUTH_GATEWAY = :production
else
    AUTH_GATEWAY = :sandbox
end


RESQUE_AUTH = if Rails.env.development? or Rails.env.test?
    "Dboard77"
else
    ENV['RESQUE_AUTH']
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

AUTHORIZE_MOBILE_DEVICE = if Rails.env.development? or Rails.env.test?
    '42741F4C-3C79-4C57-BF12-0591BFBB7956'
else
    ENV['AUTHORIZE_MOBILE_DEVICE']
end

MAILCHIMP_APIKEY = if Rails.env.development? or Rails.env.test?
    '925c032769638d199309b7c752c31700-us7'
else
    ENV['MAILCHIMP_APIKEY']
end

MAILCHIMP_LIST_ID = if Rails.env.development? or Rails.env.test?
    'b29e278ebe'
else
    ENV['MAILCHIMP_LIST_ID']
end

# MANDRILL is located in config/initializers/mandrill.rb

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

SLICKTEXT_PRIVATE =  if Rails.env.development? or Rails.env.test?
    "0cc8841e131a2ecdc690a4d2e7b5a676255e26a8"
else
    ENV['SLICKTEXT_PRIVATE']
end

NEXT_GEN_USER = if Rails.env.development? or Rails.env.test?
    'jfwwejfkslopwe'
else
    ENV['NEXT_GEN_USER']
end

NEXT_GEN_PASS = if Rails.env.development? or Rails.env.test?
    'hY9ek8Kkawpo2qQ8hE52l_qe8I'
else
    ENV['NEXT_GEN_PASS']
end

POSITRONICS_API_KEY = if Rails.env.development? or Rails.env.test?
    '203d714b6a3642379ce7ccbabe4e9926'
else
    ENV['POSITRONICS_API_KEY']
end

POSITRONICS_API_URL = "https://api.omnivore.io/0.1"











