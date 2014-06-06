namespace :gifts do

    desc "expire gifts"
    task expire: :environment do
        require 'expiration'
        Expiration::expire_gifts
    end

end