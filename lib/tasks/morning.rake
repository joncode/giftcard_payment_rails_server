namespace :morning do

    desc "demo gifts"
    task cron: :environment do
    		# generate admin reports
    	puts "MORNING CRON #{DateTime.now.utc} - DAILY_REPORT_SYS"
    	puts Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
    		puts "MORNING CRON #{DateTime.now.utc} - WEEKLY_REPORT_SYS"
			puts Alert.perform('WEEKLY_REPORT_SYS')
		end

        if DateTime.now.utc.wednesday?
            puts "MORNING CRON #{DateTime.now.utc} - NEW_CLIENTS_WEEKLY_SYS"
            puts Alert.perform('NEW_CLIENTS_WEEKLY_SYS')
        end

    end

end