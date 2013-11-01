namespace :email do

    task gift_emails_count: :environment do
		require 'mandrill'

    	start_date  = 5.days.ago.beginning_of_day

    	created_gifts = Gift.where("created_at > ?", start_date)
		m = Mandrill::API.new(MANDRILL_APIKEY)
		# response = m.messages.search({"date_from" => start_date.strftime("%m/%d/%Y")}, {"date_to" => Time.now.strftime("%m/%d/%Y")})
		response = m.messages.search("gift", start_date.strftime("%m/%d/%Y"), Time.now.strftime("%m/%d/%Y"))
		# response = m.messages.search

		info_emails    = []
		notify_emails  = []
		invoice_emails = []
		other_emails   = []
		response.each do |r|
			if r["email"] == "info@drinkboard.com"
				info_emails << r
			elsif r["subject"].include? "sent you a gift on Drinkboard"
				notify_emails << r
			elsif r["subject"] == "Your purchase is complete"
				invoice_emails << r
			else
				other_emails << r
			end
		end

		puts "----------------------------------------------------------------------------------"
		puts "----------------------------------------------------------------------------------"
		puts "------------------------ RAKE EMAIL:GIFT_EMAILS_COUNT ---------------------------"
		puts "----------------------------------------------------------------------------------"
		created_gifts.all.each do |g|
			unless notify_emails.include? g.receiver_email
				puts "   notify_receiver email not sent - gift #{g.id} - #{g.receiver_email}"
			end
			giver_email = g.giver.email
			unless invoice_emails.include? giver_email
				puts "   invoice_giver email not sent   - gift #{g.id} - #{giver_email}"
			end
		end
		puts "----------------------------------------------------------------------------------"
		puts "   Total Gifts Created            - #{created_gifts.count} gifts"
		puts "" 
		puts "   Invoice Giver emails           - #{invoice_emails.count} emails"
		puts "   Notify Receiver emails         - #{notify_emails.count} emails"
		puts "   Other emails                   - #{other_emails.count} emails"
		puts "   info@drinkboard.com emails     - #{info_emails.count} emails"
		puts "   TOTAL                          - #{response.count} total emails"
		puts "----------------------------------------------------------------------------------"
		puts "----------------------------------------------------------------------------------"

	end


end