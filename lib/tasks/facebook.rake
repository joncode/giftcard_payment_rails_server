namespace :facebook do

    desc "facebook cron"
    task cron: :environment do
        FacebookCronJob.perform
    end

end