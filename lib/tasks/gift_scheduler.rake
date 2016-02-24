namespace :gifts do

    desc "deliver scheduled gifts"
    task scheduler: :environment do
    	GiftScheduledJob.perform
    end

end