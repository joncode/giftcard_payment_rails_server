module GiftAnalyticDaily


	def self.recalculate
		GiftAnalytic.delete_all

        Gift.find_in_batches do |group|
            group.each do |gift|
            	GiftAnalytic.calculate_all(gift)
            end
        end

	end

	def self.run_cron
		puts "\n CRON DATE CHECKS"
		datetime       = Time.now.utc
		puts "\n datetime.inspect #{datetime.inspect} \n"
		ga_date        = GiftAnalytic.return_date(datetime)
		puts "\n ga_date.inspect #{ga_date.inspect} \n"
		last_date      = ga_date - 1.day
		puts "\n last_date.inspect #{last_date.inspect} \n"
		last_ga_date   = GiftAnalytic.order(date_on: :desc).limit(1).first.date_on
		puts "\n last_ga_date.inspect #{last_ga_date.inspect}\n"
		first_date     = last_ga_date + 1.day
		puts "\n first_date.inspect #{first_date.inspect}\n"
		scope_datetime = first_date.to_datetime.beginning_of_day.change(hour: 14)
		puts "\n scope_datetime.inspect #{scope_datetime.inspect}\n"

		Gift.where('created_at >= ?', scope_datetime).find_in_batches do |group|
			group.each do |gift|
				c_ga = nil
				n_ga = nil

				c_date = GiftAnalytic.return_date(gift.created_at)
				if  c_date && c_date >= first_date && c_date < last_date
					c_ga = GiftAnalytic.calculate_created_at(gift)
				end
			end
		end

		Gift.where('notified_at >= ?', scope_datetime).find_in_batches do |group|
			group.each do |gift|
				n_date = GiftAnalytic.return_date(gift.notified_at)
				if  n_date && n_date >= first_date && n_date < last_date
					n_ga = GiftAnalytic.calculate_notified_at(gift, nil)
				end
			end
		end

		Gift.where('redeemed_at >= ?', scope_datetime).find_in_batches do |group|
			group.each do |gift|
				r_date = GiftAnalytic.return_date(gift.redeemed_at)
				if r_date && r_date >= first_date && r_date < last_date
					r_ga = GiftAnalytic.calculate_redeemed_at(gift, nil, nil)
				end
			end
		end
	end
end