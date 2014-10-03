class PushUserBulkJob

    @queue = :push_bulk

    def self.perform alert
    	user_ids = PnToken.pluck(:user_id)
    	user_ids.uniq!
    	user_ids.each do |user_id|
    		if User.where(id: user_id).present?
	        	Resque.enqueue(PushUserJob, alert, user_id)
        	else
        		puts "Could not find user with id #{}"
        	end
    	end
    end

end
