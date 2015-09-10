UA = Urbanairship
if Rails.env.production?
    UA_CLIENT = UA::Client.new(key: ENV['UAAPPLICATION_KEY'], secret: ENV['UAMASTER_SECRET'])
else
    UA_CLIENT = UA::Client.new(key: 'q_NVI6G1RRaOU49kKTOZMQ', secret: 'Lugw6dSXT6-e5mruDtO14g')
end

# push = UA_CLIENT.create_push
# # push.audience = UA.device_token("a847e3c1b8e697155b35d3d5ea3ee38b0cf6d3cb8b7a257b7496df12737f0b3d")
# push.audience = UA.alias(u.ua_alias)
# push.notification = UA.notification(alert: 'Testing from alias')
# push.device_types = UA.all
# push.send_push

