namespace :cache do

    desc "rebuild Redis Cache"
    task rebuild: :environment do
        RedisCacheControl::perform
    end

end