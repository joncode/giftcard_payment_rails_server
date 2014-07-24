class Relay

	class << self

		def send_push_notification gift

			if gift.receiver_id
                puts "\nNotify Receiver via Push #{gift.receiver_name}"
				Resque.enqueue(PushJob, gift.id)
			end

		end

        def send_boomerang_push_notification(gift)
            Resque.enqueue(BoomerangPushJob, gift.id)
        end

        def send_push_thank_you gift
            Resque.enqueue(PushJob, gift.id, true)
        end

        def send_push_incomplete gift
            if gift.giver_type == "User"
                Resque.enqueue(PushJob, gift.id, true, true)
                # email_gift_collected(g)
            end
        end
	end

end
