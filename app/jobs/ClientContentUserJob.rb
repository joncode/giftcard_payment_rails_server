class ClientContentUsersJob
    @queue = :after_save

    def self.perform client_id, user_id

    	client = Client.find client_id

    	if !client.full?
    		user = User.find user_id
    		if user
	    		client.content = user
	    	end
    	end

    end

end