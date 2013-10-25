if Rails.env.production?
    Urbanairship.application_key    = ENV['UAAPPLICATION_KEY']
    Urbanairship.application_secret = ENV['UAAPPLICATION_SECRET']
    Urbanairship.master_secret      = ENV['UAMASTER_SECRET']
    Urbanairship.logger             = Rails.logger
    Urbanairship.request_timeout    = 5 # default
else
    Urbanairship.application_key    = 'q_NVI6G1RRaOU49kKTOZMQ'
    Urbanairship.application_secret = 'yQEhRtd1QcCgu5nXWj-2zA'
    Urbanairship.master_secret      = 'Lugw6dSXT6-e5mruDtO14g'
    Urbanairship.logger             = Rails.logger
    Urbanairship.request_timeout    = 5 # default
end
    
