class ProtoGifterJob

	@queue = :gifting

	def self.perform(proto_id)

		puts "\nIn ProtoGifterJob for proto #{proto_id}\n"
		proto = Proto.find(proto_id)

		if Rails.env.production? || Rails.env.staging?
			batch 	  = 200
			wait_time = 1
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

	end

end


