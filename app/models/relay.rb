class Relay

	class << self

		def send_push_notification gift

			if gift.receiver_id
				Resque.enqueue(PushJob, gift.id)
			end

		end

        def send_push_thank_you gift
            Resque.enqueue(PushJob, gift.id, true)
        end
	end

end
