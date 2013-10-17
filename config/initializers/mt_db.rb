class Mtmodel < ActiveRecord::Base
    self.abstract_class = true
    if Rails.env.production? || Rails.env.staging?
        establish_connection(
            ENV['MT_DATABASE_URL']
        )
    else
        establish_connection "mt_#{Rails.env}"
    end

end