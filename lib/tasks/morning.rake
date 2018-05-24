namespace :morning do

    desc "runs once per day"
    task cron: :environment do

    		# generate admin reports
        start_time = DateTime.now.utc
    	puts "MORNING CRON Start #{start_time} "

        begin
            puts Alert.perform('DAILY_REPORT_SYS')
        rescue => e
            puts "500 Internal DAILY_REPORT_SYS #{e.inspect}"
        end

        begin
            if DateTime.now.utc.monday?
                puts "MORNING CRON #{DateTime.now.utc} - WEEKLY_REPORT_SYS"
                Alert.perform('WEEKLY_REPORT_SYS')
            end
        rescue => e
            puts "500 Internal WEEKLY_REPORT_SYS #{e.inspect}"
        end

        begin
            if DateTime.now.utc.day == 2
                puts "MORNING CRON #{DateTime.now.utc} - MONTHLY_REPORT_SYS"
                Alert.perform('MONTHLY_REPORT_SYS')
            end
        rescue => e
            puts "500 Internal MONTHLY_REPORT_SYS #{e.inspect}"
        end

        begin
            if DateTime.now.utc.wednesday?
                puts "MORNING CRON #{DateTime.now.utc} - NEW_CLIENTS_WEEKLY_SYS"
                Alert.perform('NEW_CLIENTS_WEEKLY_SYS')
            end
        rescue => e
            puts "500 Internal NEW_CLIENTS_WEEKLY_SYS #{e.inspect}"
        end

        begin
            Proto.start_and_stop_bonus_promos
        rescue => e
            puts "500 Internal Proto.start_and_stop_bonus_promos #{e.inspect}"
        end

        begin
            Booking.reminders
        rescue => e
            puts "500 Internal Booking.reminders #{e.inspect}"
        end

        begin
            Proto.destroy_incomplete_protos  # delete incomplete bad proto data that is old
        rescue => e
            puts "500 Internal destroy_incomplete_protos #{e.inspect}"
        end

        begin
            ListByStateMakerJob.perform
        rescue => e
            puts "500 Internal ListByStateMakerJob #{e.inspect}"
        end

        begin
            Alert.perform('EPSON_PRINTER_DAILY_ISSUES_REPORT_SYS')
        rescue => e
            puts "500 Internal Epson Printer Daily Issues Report #{e.inspect}"
        end

        end_time = DateTime.now.utc.to_i - start_time.to_i
        puts "MORNING CRON End #{end_time} seconds"
    end

end