require 'sms_collector'

namespace :promo do

    desc "slicktext promo"
    task slicktext: :environment do
        # SmsCollector::sms_promo_run
    end

end