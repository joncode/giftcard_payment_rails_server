namespace :morning do

    desc "demo gifts"
    task cron: :environment do

    		# generate admin reports
    	Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
			Alert.perform('WEEKLY_REPORT_SYS')
		end

			# generate mt reports
  #   	Alert.perform('DAILY_REPORT_MT')
  #   	if DateTime.now.utc.monday?
		# 	Alert.perform('WEEKLY_REPORT_MT')
		# end
    end

end