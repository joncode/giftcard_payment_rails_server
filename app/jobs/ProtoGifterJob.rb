require 'resque/errors'

class ProtoGifterJob

	@queue = :gifting

	def self.perform(proto_id)

		puts "\nIn ProtoGifterJob for proto #{proto_id}\n"
		proto = Proto.find(proto_id)

		if Rails.env.production?
			batch 	  = 200
			wait_time = 1
		elsif Rails.env.staging?
			batch 	  = 200
			wait_time = 0
		else
			batch 	  = 1
			wait_time = 0.1
		end

		proto.giftables.find_in_batches(batch_size: batch) do |group_ary|

			group_ary.each do |proto_join|

				gift = GiftProtoJoin.create({ "proto_join" => proto_join, "proto" => proto})

				puts "\n proto has created gift ... "

				if gift.errors.messages.count > 0
					puts "Gift Error = #{gift.errors.messages} for #{gift.inspect}"
				end

				sleep wait_time

				puts "\n proto wait is finished looping to make another ..."
			end

		end

	rescue Resque::TermException
		restart(proto_id, "TermException")
	rescue Resque::DirtyExit
		restart(proto_id, "DirtyExit")
	rescue Exception => e
	    if e.message =~ SIGTERM
	    	restart(proto_id, e.inspect)
	    else
	    	raise
	    end
	end

private

	def restart(object_id, exception_type)

		puts log_bars "Hit the RESQUE #{exception_type} - restarting in 20 seconds"
		sleep 20
	    Resque.enqueue(ProtoGifterJob, proto_id)
	end

end


