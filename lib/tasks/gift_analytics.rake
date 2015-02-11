namespace :gifts do

    desc "GIFT ANALYTICS"
    task analytics: :environment do
        GiftAnalyticDaily::run_cron
    end

end