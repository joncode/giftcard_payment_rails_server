namespace :cache do

    desc "monitor Redis Cache"
    task monitor: :environment do
        RedisCacheMonitor::perform
    end

end