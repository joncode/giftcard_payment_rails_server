namespace :minute do

    desc "every ten minutes cron"
    task cron: :environment do

        Redemption.expire_stale_tokens
        UserSocial.double_check_incomplete_gifts
    end

end