Airship =
    if Rails.env.production?
        Urbanairship::Client.new(
            key:    ENV['UAAPPLICATION_KEY'],
            secret: ENV['UAMASTER_SECRET']
        )
    else
        Urbanairship::Client.new(
            key:    'q_NVI6G1RRaOU49kKTOZMQ',
            secret: 'Lugw6dSXT6-e5mruDtO14g'
        )
    end

UA = Urbanairship
