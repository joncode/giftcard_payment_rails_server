namespace :gifts do

    desc "expire gifts"
    task expire: :environment do
        lcon
        Expiration::expire_gifts
    end

end