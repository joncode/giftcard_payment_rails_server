class DittoJob

	@queue = :subscription


	def self.perform sender_str, status, args, notable_id=nil, notable_type=nil

		args['sender'] = sender_str
		Ditto.save_response(args, status, notable_id, notable_type)

	end


end