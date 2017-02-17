namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do
    	Dir[Rails.root.join("app/accounting/*.rb")].each { |f| require f }
    	begin
	    	AccountsReceivableCronJob.perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR #{e.inspect}"
	    end
	    begin
		    puts AccountsPayableCronJob::perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR 2 #{e.inspect}"
	    end
	    begin
		    puts PaymentSyncCronJob::perform
	    rescue => e
	    	puts "500 Internal PAYMENT CALCULATOR 3 #{e.inspect}"
	    end
    end

end