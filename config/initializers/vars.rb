# MANDRILL
MAILCHIMP_APIKEY = '925c032769638d199309b7c752c31700-us7'
CATCH_PHRASE = "Theres no place like home"

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
