namespace :morning do

    desc "demo gifts"
    task cron: :environment do

    begin
    		# generate admin reports
    	puts "MORNING CRON #{DateTime.now.utc} - DAILY_REPORT_SYS"
    	puts Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
    		puts "MORNING CRON #{DateTime.now.utc} - WEEKLY_REPORT_SYS"
			Alert.perform('WEEKLY_REPORT_SYS')
		end

        if DateTime.now.utc.day == 2
            puts "MORNING CRON #{DateTime.now.utc} - MONTHLY_REPORT_SYS"
            Alert.perform('MONTHLY_REPORT_SYS')
        end

        if DateTime.now.utc.wednesday?
            puts "MORNING CRON #{DateTime.now.utc} - NEW_CLIENTS_WEEKLY_SYS"
            Alert.perform('NEW_CLIENTS_WEEKLY_SYS')
        end

        Proto.destroy_incomplete_protos  # delete incomplete bad proto data that is old
        ListByStateMakerJob.perform

        Booking.reminders
    rescue => e
        puts "500 Internal MORNING CRON FAIL #{e.inspect}"
    end

end