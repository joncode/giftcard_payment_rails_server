namespace :morning do

    desc "demo gifts"
    task cron: :environment do
    		# generate admin reports
    	Alert.perform('DAILY_REPORT_SYS')
    	puts "MORNING CRON #{DateTime.now.utc} - DAILY_REPORT_SYS"
    	puts Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
    		puts "MORNING CRON #{DateTime.now.utc} - WEEKLY_REPORT_SYS"
			puts Alert.perform('WEEKLY_REPORT_SYS')
		end

			# generate mt reports
  #   	Alert.perform('DAILY_REPORT_MT')
  #   	if DateTime.now.utc.monday?
		# 	Alert.perform('WEEKLY_REPORT_MT')
		# end
    end

end