namespace :push do

    desc "update Urban Airship data"
    task update_urbanairship: :environment do
        lcon
        check_update_aliases
        register_missing_pn_tokens
    end

end