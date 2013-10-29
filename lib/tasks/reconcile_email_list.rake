namespace :email do

    task reconcile_list: :environment do
    	start_time = 2.days.ago
		us_users = UserSocial.where('created_at >= ? AND type_of = ?', start_time, "email")

		subscribes_sent = []
		us_users.all.each do |u|
			if u.subscribed == true
				subscribes_sent += 1
			else
				user = User.find(u.user_id)
				puts "----- #{user.name}(ID#{user.id}) created a UserSocial email #{u.identifier} but didn't get sent an email."
			end
		end
	  	puts "TOTALS"
	  	puts "----------- #{us_users.count} UserSocials created since #{start_time}"
	  	puts "----------- #{subscribes_sent.count} subscribe requests sent since #{start_time}"


	  	

	  	
	end


end