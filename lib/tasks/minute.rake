namespace :minute do

    desc "every ten minutes cron"
    task cron: :environment do

        Redemption.expire_stale_tokens

    end

end