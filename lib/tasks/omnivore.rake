namespace :omnivore do

    desc "omnivore cron"
    task cron: :environment do
        OmnivoreCronJob.perform
    end

end