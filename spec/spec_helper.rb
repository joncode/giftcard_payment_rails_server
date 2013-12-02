# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'resque_spec'
require 'capybara/rails'
require 'capybara/rspec'
require 'webmock/rspec'
#require 'documentation_helper'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }


alias running proc

RSpec.configure do |config|
    config.use_transactional_fixtures = false

    WebMock.disable_net_connect!(allow_localhost: true)
    config.include Capybara::DSL
    config.include Capybara::RSpecMatchers
end