source 'https://rubygems.org'
ruby '2.0.0'

gem 'rails', '4.0.0'
gem 'pg'
gem 'unicorn'
gem "rack-timeout"
gem 'httparty', '~> 0.9.0'
gem 'resque', :require => "resque/server"
gem 'newrelic_rpm'
gem 'authorize-net'
gem 'mandrill-api', "~> 1.0.35"
gem 'mailchimp-api'
gem 'json', '~> 1.7.7'
gem "namecase", "~> 1.1.0"       # capitalizes names like "McDonald" correctly
gem 'rails_12factor'

gem 'protected_attributes'


group :development do
	gem 'annotate', '~> 2.4.1.beta'
end

group :development, :test do
  gem 'rb-fsevent', '~> 0.9.1'
  gem "guard"
  gem "guard-rspec"
  gem "rspec-rails", "~> 2.13.0"
  gem "factory_girl"
  gem "yajl-ruby"
end

group :test do
  gem "capybara",    "2.0.3"
  gem "launchy"
  gem 'webmock'
  gem 'resque_spec'
end

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '~> 3.0.0'

gem 'activemerchant'
gem 'urbanairship'


###########   GEMS WE DO NOT NEED  ################
# deprecated gems
# gem 'will_paginate', '> 3.0'
# gem 'roadie'
# gem 'carrierwave'
# gem 'cloudinary'

# can remove twitter bootstrap etc
# group :assets do
#   gem 'sass-rails',   '~> 3.2.3'
#   gem 'coffee-rails', '~> 3.2.1'
#   gem 'uglifier', '>= 1.2.3'
# end

# gem "twitter-bootstrap-rails", "~> 2.0.1.0"
# gem 'jquery-rails'
