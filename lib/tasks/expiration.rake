namespace :gifts do

    desc "expire gifts"
    task expire: :environment do
        require 'expiration'
        Expiration::expire_gifts
        Expiration::destroy_sms_contacts
        Expiration::destroy_expired_cards
    end

end