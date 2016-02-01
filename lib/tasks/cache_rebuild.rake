namespace :cache do

    desc "rebuild Redis Cache"
    task rebuild: :environment do
        RedisCacheControl::perform
        WwwHttpService.clear_merchant_cache
    end

end