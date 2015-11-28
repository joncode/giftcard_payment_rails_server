namespace :push do

    desc "update Urban Airship data"
    task update_urbanairship: :environment do
        puts " ----------------------   300 CRON UA cron ---------------------------------"
        lcon
        check_update_aliases
        register_missing_pn_tokens
        puts "-------------------------- 300 CRON end UA cron  -----------------------------"
    end

end
