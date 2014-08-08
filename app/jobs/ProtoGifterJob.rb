require 'resque/plugins/resque_heroku_autoscaler'

require 'resque/errors'

class ProtoGifterJob
    extend Resque::Plugins::HerokuAutoscaler

	@queue = :gifting

	def self.perform(proto_id, re_run_amount=0)

		puts "\nIn ProtoGifterJob for proto #{proto_id}\n"
		proto = Proto.find(proto_id)

		if Rails.env.production?
			batch 	  = 200
			wait_time = 0.5
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
				proto.update_processed(1)
				puts "\n proto has created gift ... "

				if gift.errors.messages.count > 0
					puts "Gift Error = #{gift.errors.messages} for #{gift.inspect}"
				end

				sleep wait_time

				puts "\n proto wait is finished looping to make another ..."
			end

		end

		puts "\nProtoGifterJob COMPLETE #{proto_id}\n"

		if proto.contacts > proto.processed
			# re-run
			left_over = proto.contacts - proto.processed
			unless left_over == re_run_amount
				self.restart(proto, "Contacts Exceed Processed", left_over)
			end
		end

	rescue Resque::TermException
		self.restart(proto, "RESQUE TermException", re_run_amount)
	rescue Resque::DirtyExit
		self.restart(proto, "RESQUE DirtyExit", re_run_amount)
	rescue Exception => e
	    if e.message =~ /SIGTERM/
	    	self.restart(proto, "RESQUE e.inspect", re_run_amount)
	    else
	    	raise
	    end
	end

private

	def self.restart(object, exception_type, left_over=0)

		log_bars "Hit the #{exception_type} - restarting in 20 seconds"
		sleep 20
	    Resque.enqueue(ProtoGifterJob, object.id, left_over)
	end

end


