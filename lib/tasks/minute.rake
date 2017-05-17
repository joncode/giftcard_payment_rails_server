namespace :minute do

    desc "every ten minutes cron"
    task cron: :environment do

        start_time = DateTime.now.utc
    	puts "MINUTE CRON Start #{start_time} "

        begin
            bank_ary = Bank.where('created_at > ?', 10.minutes.ago)
            Alert.perform("BANK_ADDED_SYS", bank_ary) unless bank_ary.empty?
        rescue => e
            puts "500 Internal Bank.created_at.10.minutes #{e.inspect}"
        end

        begin
            Redemption.expire_stale_tokens
        rescue => e
            puts "500 Internal Redemption.expire_stale_tokens #{e.inspect}"
        end

        begin
            UserSocial.double_check_incomplete_gifts
        rescue => e
            puts "500 Internal UserSocial.double_check_incomplete_gifts #{e.inspect}"
        end

        end_time = DateTime.now.utc.to_i - start_time.to_i
        puts "MINUTE CRON End #{end_time} seconds"
    end

end