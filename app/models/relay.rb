class Relay

	class << self

		def send_push_notification gift
				# get the user tokens from the pn_token db
			if Rails.env.production? || Rails.env.staging?
				if gift.receiver_id
					Resque.enqueue(PushJob, gift.id)
				end
			end

		end
	end

end
