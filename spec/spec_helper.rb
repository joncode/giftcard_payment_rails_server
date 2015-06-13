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
Dir[Rails.root.join("spec/shared/*.rb")].each { |f| require f }
Dir[Rails.root.join("spec/factories/*.rb")].each { |f| require f }


alias running proc

RSpec.configure do |config|
    config.before(:suite) { ActiveRecord::Migration.maintain_test_schema! }
    config.use_transactional_fixtures = false

    WebMock.disable_net_connect!(allow_localhost: true)
    config.include Capybara::DSL
    config.include Capybara::RSpecMatchers

    begin
        Gift.exists?
        gift = FactoryGirl.create(:gift, receiver_id: 2, status: 'open')
        gift.notify
    rescue
        sql = "CREATE SEQUENCE gift_token_seq MINVALUE 1000 MAXVALUE 9999 CACHE 100 CYCLE;"
        begin
            Gift.connection.execute(sql)
        rescue => e
            puts e
        end
    ensure
        gift.destroy! if gift
    end

end
