namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do
        PaymentCalcCronJob::perform
    end

end