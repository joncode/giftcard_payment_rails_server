namespace :email do


	task mc_subscriptions: :environment do
		start_date = 5.days.ago.beginning_of_day
		created_us = UserSocial.where(active: true, subscribed:false).where("type_of = ? AND created_at > ?", "email", start_date)

		puts "----------------------------------------------------------------------------------"
		puts "----------------------------------------------------------------------------------"
		puts "---------- RAKE EMAIL:MC_SUBSCRIPTIONS SINCE #{start_date} ----------"
		puts "----------------------------------------------------------------------------------"
		created_us.each do |u|
            Resque.enqueue(SubscriptionJob, u.id)
			puts "   Sent unsubscribed email to Queue           - UserSocial #{u.id} - User #{u.user_id} - email #{u.identifier}"
		end
		puts "----------------------------------------------------------------------------------"

	end


    task gift_emails_count: :environment do
		require 'mandrill'

    	start_date  = 10.days.ago.beginning_of_day

    	created_gifts = Gift.where("created_at > ?", start_date)
		m = Mandrill::API.new(MANDRILL_APIKEY)
		response = m.messages.search("gift", start_date.strftime("%m/%d/%Y"), Time.now.strftime("%m/%d/%Y"))

		info_emails    = []
		notify_emails  = []
		invoice_emails = []
		other_emails   = []
		response.each do |r|
			if r["email"] == INFO_EMAIL
				info_emails << r
			elsif r["subject"].include? "sent you a gift on #{SERVICE_NAME}"
				notify_emails << r["email"]
			elsif r["subject"] == "Your gift purchase is complete"
				invoice_emails << r["email"]
			else
				other_emails << r
			end
		end

		puts "----------------------------------------------------------------------------------"
		puts "----------------------------------------------------------------------------------"
		puts "---------- RAKE EMAIL:GIFT_EMAILS_COUNT SINCE #{start_date} ----------"
		puts "----------------------------------------------------------------------------------"
		created_gifts.each do |g|

			unless notify_emails.include? g.receiver_email
				puts "   notify_receiver email not sent - gift #{g.id} - #{g.receiver_email}"
				# unless Rails.env.development?
				# 	puts "   resending to notify_receiver queue"
				# 	g.notify_receiver
				# end
			end
			giver_email = g.giver.email
			unless invoice_emails.include? giver_email
				puts "   invoice_giver email not sent   - gift #{g.id} - #{giver_email}"
				# unless Rails.env.development?
				# 	puts "    resending to invoice_giver queue"
				# 	g.invoice_giver
				# end
			end
		end
		puts "----------------------------------------------------------------------------------"
		puts "   Total Gifts Created            - #{created_gifts.count} gifts"
		puts "" 
		puts "   Invoice Giver emails           - #{invoice_emails.count} emails"
		puts "   Notify Receiver emails         - #{notify_emails.count} emails"
		puts "   Other emails                   - #{other_emails.count} emails"
		puts "   #{INFO_EMAIL} emails     - #{info_emails.count} emails"
		puts "   TOTAL                          - #{response.count} total emails"
		puts "----------------------------------------------------------------------------------"
		puts "----------------------------------------------------------------------------------"

	end


end