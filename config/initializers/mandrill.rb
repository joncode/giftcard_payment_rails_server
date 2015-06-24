MANDRILL_APIKEY = if Rails.env.test?
    'pOqNDraZxOFoF44X0pbR-Q'
elsif Rails.env.development?
    # 'pOqNDraZxOFoF44X0pbR-Q' #mandrill_apikey_test
    'oUXP1PDOtP14RMgFytxdGw'
elsif Rails.env.staging?
    #ENV['MANDRILL_APIKEY_TEST']
    ENV['MANDRILL_APIKEY']
else
    ENV['MANDRILL_APIKEY']
end

require 'mandrill'

MANDRILL_CLIENT = Mandrill::API.new(MANDRILL_APIKEY)
