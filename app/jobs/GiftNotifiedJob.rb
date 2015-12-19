class GiftNotifiedJob

	@queue = :database

    def self.perform loc_id

    	# call list tickets at location
    	# paginate thru and get all the tickets
    	# separate the tickets
    	# save each ticket into Redis with key "pos:omnivore:location:#{loc_id}:ticket:#{ticket_num}"
    	# set expiration to be 2 hours



    end

end