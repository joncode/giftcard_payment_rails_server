namespace :push do

    desc "update Urban Airship data"
    task update_urbanairship: :environment do
        puts " ----------------------   UA cron ---------------------------------"
        lcon
        check_update_aliases
        register_missing_pn_tokens
        puts "-------------------------- end UA cron  -----------------------------"
    end

end