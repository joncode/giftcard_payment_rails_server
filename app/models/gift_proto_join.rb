class GiftProtoJoin < Gift
    include GiftMessenger

#   -------------

    def self.create args={}
    	proto, proto_join = self.process_input args
    	args = self.pre_init(proto, proto_join)
        gift = super
        if gift.persisted?
            gift.messenger_proto_join
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
		args['merchant_id']   = proto.merchant_id
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


end# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#

# == Schema Information
#
# Table name: gifts
#
#  id             :integer         not null, primary key
#  giver_name     :string(255)
#  receiver_name  :string(255)
#  provider_name  :string(255)
#  giver_id       :integer
#  receiver_id    :integer
#  credit_card    :string(100)
#  provider_id    :integer
#  message        :text
#  status         :string(255)     default("unpaid")
#  created_at     :datetime        not null
#  updated_at     :datetime        not null
#  receiver_phone :string(255)
#  facebook_id    :string(255)
#  receiver_email :string(255)
#  shoppingCart   :text
#  twitter        :string(255)
#  service        :string(255)
#  order_num      :string(255)
#  cat            :integer         default(0)
#  active         :boolean         default(TRUE)
#  pay_stat       :string(255)
#  redeemed_at    :datetime
#  server         :string(255)
#  payable_id     :integer
#  payable_type   :string(255)
#  giver_type     :string(255)
#  value          :string(255)
#  expires_at     :datetime
#  refund_id      :integer
#  refund_type    :string(255)
#  cost           :string(255)
#  detail         :text
#  ftmeta         :tsvector
#  notified_at    :datetime
#  new_token_at   :datetime
#  token          :integer
#  balance        :integer
#  origin         :string(255)
#

