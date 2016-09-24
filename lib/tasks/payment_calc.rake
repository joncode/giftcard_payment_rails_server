namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do
    	begin
	    	AccountsReceivableCronJob.perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR #{e.inspect}"
	    end
        AccountsPayableCronJob::perform
    end

end