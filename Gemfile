source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails'
gem 'pg'
gem 'unicorn'
gem "rack-timeout"
gem 'httparty', '~> 0.9.0'
gem 'resque', :require => "resque/server"
gem "resque-retry"
#gem 'newrelic_rpm'
gem 'authorize-net'
gem 'mandrill-api', "~> 1.0.35"
gem 'mailchimp-api'
gem 'json', '~> 1.7.7'
gem "namecase", "~> 1.1.0"       # capitalizes names like "McDonald" correctly
gem 'rails_12factor'
gem 'bcrypt-ruby'
gem 'activemerchant'
gem 'urbanairship'
gem 'roo'
gem 'resque-heroku-autoscaler', "~> 0.3.1.12", git: 'https://github.com/joncode/resque-heroku-autoscaler.git'


group :development do
	gem 'annotate', '~> 2.4.1.beta'
end

group :development, :test do
  gem "capybara",    "1.1.2"
  gem 'rb-fsevent', '~> 0.9.1'
  gem "guard"
  gem "guard-rspec"
  gem "rspec-rails", "~> 2.13.0"
  gem "factory_girl"
  gem "yajl-ruby"
end

group :test do
  gem "launchy"
  gem 'webmock'
  gem 'resque_spec'
  gem 'database_cleaner'
  gem 'rest-client'
  gem 'minitest'
end


