RSpec.configure do |config|

  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
    if Region.city.nil? || Region.city.count == 0
        load "#{Rails.root}/db/seeds.rb"
    end
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end