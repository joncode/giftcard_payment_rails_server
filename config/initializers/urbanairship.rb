if Rails.env.production?
    Urbanairship.application_key    = 'pgM5UjUvRaSGsxCQs2JkfA'
    Urbanairship.application_secret = 'haOyK9IEScuguPw1z3N0Ew'
    Urbanairship.master_secret      = 'nMU0qujYRTSGgzSMyz_H2A'
    Urbanairship.logger             = Rails.logger
    Urbanairship.request_timeout    = 5 # default
else
    Urbanairship.application_key    = 'q_NVI6G1RRaOU49kKTOZMQ'
    Urbanairship.application_secret = 'yQEhRtd1QcCgu5nXWj-2zA'
    Urbanairship.master_secret      = 'Lugw6dSXT6-e5mruDtO14g'
    Urbanairship.logger             = Rails.logger
    Urbanairship.request_timeout    = 5 # default
end