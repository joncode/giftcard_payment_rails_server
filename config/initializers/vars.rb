if Rails.env.production?
    AUTH_GATEWAY = :production
else
    AUTH_GATEWAY = :sandbox
end

ENV['CATCH_PHRASE'] = if Rails.env.development? or Rails.env.test?
    "Theres no place like home"
end

ENV['CCS_KEY'] = if Rails.env.development? or Rails.env.test?
    "Yes yes yes"
end

ENV['AUTHORIZE_API_LOGIN'] = if Rails.env.development?
    '948bLpzeE8UY'
end

ENV['AUTHORIZE_TRANSACTION_KEY'] = if Rails.env.development?
    '7f7AZ66axeC386q7'
end

ENV['MAILCHIMP_APIKEY'] = if Rails.env.development? or Rails.env.test?
    '925c032769638d199309b7c752c31700-us7'
end

ENV['MANDRILL_APIKEY'] = if Rails.env.development? or Rails.env.test?
    'oUXP1PDOtP14RMgFytxdGw'
end

ENV['MAILCHIMP_LIST_ID'] = if Rails.env.development? or Rails.env.test?
    'b29e278ebe'
end

ENV['GENERAL_TOKEN'] = if Rails.env.development? or Rails.env.test?
     "1964f94b3e567a8a82b87f3ccbeb2174"
end

ENV['WWW_TOKEN'] = if Rails.env.development? or Rails.env.test?
     "nj3tOdJOaZa-qFx0FhCLRQ"
end

ENV['APP_GENERAL_TOKEN'] = if Rails.env.development? or Rails.env.test?
     "0NFXbWsyP3Mj2Mroj_utsA"
end
