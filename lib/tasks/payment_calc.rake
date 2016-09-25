namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do
    	require '../../app/accounting/AccountsReceivableCronJob'
    	begin
	    	AccountsReceivableCronJob.perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR #{e.inspect}"
	    end
	    begin
		    AccountsPayableCronJob::perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR 2 #{e.inspect}"
	    end
    end

end