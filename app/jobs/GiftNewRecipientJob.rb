class GiftNewRecipientJob

	@queue = :database

    def self.perform args
    	puts "\n\nGiftNewRecipientJob.perform"
    	puts args.inspect

    	args.symbolize_keys!

    	return "BAD ARGS FAIL" unless ['change_info','giver_new_send','receiver_new_send'].include?(args[:action_type])

    	gift = Gift.unscoped.find(args[:gift_id])

    	if args[:scheduled_at].blank?
    		sched_date = gift.scheduled_at
    	else
            begin
                sched_date = TimeGem.string_stamp_to_datetime(args[:scheduled_at])
            rescue
    	    	sched_date = TimeGem.string_to_datetime(args[:scheduled_at], gift.merchant.zone)
            end
    	end

    	if args[:action_type] == 'receiver_new_send'

            regift_args = {}
            regift_args["message"]        = args[:message]
            regift_args["name"]           = args[:receiver_name]
            regift_args["email"]          = args[:receiver_email] unless args[:receiver_email].blank?
            regift_args["phone"]          = args[:receiver_phone] unless args[:receiver_phone].blank?
            regift_args["giver"]          = gift.receiver
            regift_args["old_gift_id"]    = gift.id
            regift_args["scheduled_at"] = sched_date
            gift = GiftRegift.create(regift_args)

    	elsif args[:action_type] == 'giver_new_send'


            regift_args = {}
            regift_args["message"]        = args[:message]
            regift_args["name"]           = args[:receiver_name]
            regift_args["email"]          = args[:receiver_email] unless args[:receiver_email].blank?
            regift_args["phone"]          = args[:receiver_phone] unless args[:receiver_phone].blank?
            regift_args["giver"]          = gift.giver
            regift_args["old_gift_id"]    = gift.id
            regift_args["scheduled_at"] = sched_date
            gift = GiftRegift.create(regift_args)

        elsif args[:action_type] == 'change_info'

				# change the message to new message
			gift.message = args[:message]
				# clear current receiver info
			gift.remove_receiver
				# update the gift receiver info to reflect the new
	        gift.receiver_name = args[:receiver_name]
	        gift.receiver_email = args[:receiver_email] unless args[:receiver_email].blank?
	        gift.receiver_phone = args[:receiver_phone] unless args[:receiver_phone].blank?

            gift.find_receiver
				# set schedule_at
			if sched_date.present?
				gift.scheduled_at = sched_date
			end

            gift.set_status
	        if gift.save
				# send new gift receiver email/sms notifications if not scheduled
	            GiftNotificationJob.perform('receiver', gift.id) if gift.status != 'schedule'
	        else
	            # failed
	            puts gift.errors.full_messages.inspect
	        end


    	end

		# update operation detailing results
    	operation = Operation.find(args[:operaton_id])

    	if gift.errors.blank?
    		operation.update(response: "Gift-#{gift.id}-success")
    	else
	    	operation.update(response: gift.errors.full_messages)
    	end
    end


end


# {
# 	action_type: ['change_info', 'giver_new_send', 'receiver_new_send'],
# 	receiver_name: "Dave Vanfer",
# 	receiver_email: "davevanfer@gmail.com",
# 	receiver_phone: "",
# 	scheduled_at: "09/22/2016",
# 	gift_id: 349342,
# 	operaton_id: 2341,
#   message: "Hey Happy Birthday!"
# }


