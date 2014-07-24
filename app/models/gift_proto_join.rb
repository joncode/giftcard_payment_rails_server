class GiftProtoJoin < Gift
    include GiftMessenger

#####    CLASS METHODS

    def self.create args={}
    	proto, proto_join = self.process_input args
    	args = self.pre_init(proto, proto_join)
        gift = super
        if gift.persisted?
            gift.messenger
            proto_join.update(gift_id: gift.id)
        end
        gift
    end

private

	def self.pre_init proto, proto_join
		args = {}
		proto_join.convert_to_gift_receiver(args)
		args['giver']         = proto.giver
		args['cost']          = proto.cost
		args['value']         = proto.value
		args['shoppingCart']  = proto.shoppingCart
		args['payable']       = proto
		args['message']       = proto.message
		args['detail']        = proto.detail
		args['expires_at']    = proto.expires_at
		args['cat']           = proto.cat
		args['giver']         = proto.giver
		args['provider_id']   = proto.provider_id
		args['provider_name'] = proto.provider_name
		args['receiver_name'] = GENERIC_RECEIVER_NAME if args['receiver_name'].blank?
		args
	end

	def self.process_input args
		bad_input = true

		if args["proto_join"] && args["proto_join"].kind_of?(ProtoJoin)
			proto_join = args["proto_join"]
		end

		if args["proto"] && args["proto"].kind_of?(Proto)
			proto = args["proto"]
		end

		if proto.nil? && proto_join.kind_of?(ProtoJoin)
			proto = proto_join.proto
		end

		if proto.kind_of?(Proto) && proto_join.kind_of?(ProtoJoin)
			bad_input = false
		end

		if bad_input
			raise 'Bad Input'
		end
		return proto, proto_join
	end


end