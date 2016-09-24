namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do
        AccountsPayableCronJob::perform
    end

end