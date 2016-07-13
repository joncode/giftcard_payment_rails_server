namespace :morning do

    desc "demo gifts"
    task cron: :environment do
    	puts "MORNING CRON #{DateTime.now.utc} - DAILY_REPORT_SYS"
    	puts Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
    		puts "MORNING CRON #{DateTime.now.utc} - WEEKLY_REPORT_SYS"
			puts Alert.perform('WEEKLY_REPORT_SYS')
		end
    end

end