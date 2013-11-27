class Relay

	class << self

		def send_push_notification gift
			
			if gift.receiver_id
				Resque.enqueue(PushJob, gift.id)
			end

		end
	end

end
