class Admtmodel < ActiveRecord::Base
    self.abstract_class = true
    if Rails.env.production? || Rails.env.staging?
        establish_connection(
            ENV['ADMT_DATABASE_URL']
        )
    else
        establish_connection "admt_#{Rails.env}"
    end

end