namespace :morning do

    desc "demo gifts"
    task cron: :environment do
    	Alert.perform('DAILY_REPORT_SYS')
    	if DateTime.now.utc.monday?
			Alert.perform('WEEKLY_REPORT_SYS')
		end
    end

end