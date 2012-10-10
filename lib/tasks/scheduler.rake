desc "Query Facebook Users to see if they still have the proper permissions for checkins"
task :cull_facebook_users => :environment do
  facebookEnabledUsers = User.find_by_facebook_auth_checkin(true)
  inQuery = "(#{facebookEnabledUsers.map{ |user| user[:facebook_id] }.join(",")})"
  response = HTTParty.get("https://graph.facebook.com/fql?q=select user_status, uid FROM permissions WHERE uid IN #{inQuery}")
  
  #For this part, we look at facebookEnabledUsers and remove them one by one if they exist in the permissions hash.
  disableTheseFacebookUsers = facebookEnabledUsers
  response["data"].each do |user_permission|
    if user_permission[:user_status].to_i == 1
      #We remove them from disableTheseFacebookUsers
      disableTheseFacebookUsers.delete_if{ |u| u[:facebook_id].to_s == user_permission[:uid].to_s }      
    end
  end
  
  #If we have users to disable, we update their user objects as a single transaction
  if disableTheseFacebookUsers.count > 0
    User.transaction do
      for user in disableTheseFacebookUsers
        User.update(user[:id], {:facebook_auth_checkin => false})
      end
    end    
  end
end