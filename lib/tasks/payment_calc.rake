namespace :payments do

    desc "PAYMENT CALCULATOR"
    task calc: :environment do

        start_time = DateTime.now.utc
    	puts "PAYMENT CALCULATOR Start #{start_time} "

    	Dir[Rails.root.join("app/accounting/*.rb")].each { |f| require f }
    	begin
	    	AccountsReceivableCronJob.perform
	    rescue => e
	    	puts "500 Internal AccountsReceivableCronJob.perform #{e.inspect}"
	    end
	    begin
		    puts AccountsPayableCronJob::perform
	    rescue => e
	    	puts "500 Internal AccountsPayableCronJob::perform #{e.inspect}"
	    end
	    begin
		    puts PaymentSyncCronJob::perform
	    rescue => e
	    	puts "500 Internal PaymentSyncCronJob::perform #{e.inspect}"
	    end


        end_time = DateTime.now.utc.to_i - start_time.to_i
        puts "PAYMENT CALCULATOR End #{end_time} seconds"
    end

end