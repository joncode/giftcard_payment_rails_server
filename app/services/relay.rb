class Relay

	class << self

		def send_push_notification gift

			if gift.receiver_id
                puts "\nNotify Receiver via Push #{gift.receiver_name}"
				Resque.enqueue(PushJob, gift.id, :gift_receiver_notification)
			end

		end

        def send_boomerang_push_notification(gift)
            Resque.enqueue(BoomerangPushJob, gift.id)
        end

        def send_push_thank_you gift
            if gift.notified_at >= (DateTime.now.utc - 1.minute)
                Resque.enqueue(PushJob, gift.id, :gift_received_thank_you)
            end
        end

        def send_gift_delivered gift
            Resque.enqueue(PushJob, gift.id, :gift_delivered)
        end

        def send_push_incomplete gift
            if gift.giver_type == "User"
                Resque.enqueue(PushJob, gift.id, :gift_receiver_created_account)
                # email_gift_collected(g)
            end
        end
	end

end
