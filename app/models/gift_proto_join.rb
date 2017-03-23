class GiftProtoJoin < Gift
    extend ShoppingCartHelper
    include GiftMessenger

#   -------------

    def self.create args={}
    	proto, proto_join = self.process_input args
		outside_gift = nil
    	if proto.split
    		merchant = proto.merchant
    		proto.cart_ary.each do |item_hsh|
    			item_hsh['quantity'].to_i.times do
    				ih = item_hsh.clone
    				ih['quantity'] = 1
	    			hsh = { shoppingCart: [ih].to_json }
	    			hsh[:cost] = calculate_cost(hsh[:shoppingCart], merchant)
	    			hsh[:value] = calculate_value(hsh[:shoppingCart])
	    			hsh[:ccy] = ih['ccy'] || 'USD'

					if proto_join.gift_id.present?
							# make new proto join to link to next gift
						pjn = ProtoJoin.new(gift_id: nil,
							receivable_type: proto_join.receivable_type,
							receivable_id: proto_join.receivable_id,
							proto_id: proto.id,
							rec_name: proto_join.rec_name)
						proto_join = pjn
					end

	    			args = self.create_args(proto, proto_join, hsh)
	    			gift = super args

	    			if gift.persisted?
			            proto_join.gift_id = gift.id
			            proto_join.save
			            proto.update_processed
			            outside_gift = gift
			        else
			        	# proto is bad
			        	puts "500 Internal - BAD PROTO GIFT #{gift.inspect} - #{gift.errors.messages}"
			        end
			    end
    		end
        	outside_gift
    	else
    		args = self.create_args(proto, proto_join)
        	gift = super args
	        if gift.persisted?
	            proto_join.update(gift_id: gift.id)
	            proto.update_processed
	        end
        end
        gift = outside_gift if outside_gift
        if gift.persisted?
        	if gift.status == 'schedule'
            	# send you've received scheduled gift email / text
            	gift.messenger_promo_gift_scheduled
            else
	            gift.messenger_proto_join
            end
		end
    	gift
    end

private

	def self.create_args proto, proto_join, individual_item_hsh=nil

		args = {}
		proto_join.convert_to_gift_receiver(args)

		args['giver']         = proto.giver
		if individual_item_hsh.present?
			args['cost']          = individual_item_hsh[:cost]
			args['value']         = individual_item_hsh[:value]
			args['shoppingCart']  = individual_item_hsh[:shoppingCart]
			args['ccy']  		  = individual_item_hsh[:ccy]
		else
			args['cost']          = proto.cost
			args['value']         = proto.value
			args['shoppingCart']  = proto.shoppingCart
			args['ccy']  		  = proto.ccy
		end

		args['giver']         = proto.giver
		args['merchant_id']   = proto.merchant_id
		args['provider_name'] = proto.provider_name

		args['payable']       = proto
		args['message']       = proto.message
		args['detail']        = proto.detail
		args['expires_at']    = expires_at_calc(proto)
		args['scheduled_at']  = scheduled_at_calc(proto)
		args['cat']           = proto.cat
		args['brand_card']    = proto.brand_card
		args
	end

	def self.scheduled_at_calc proto
        if proto.scheduled_at
            proto.scheduled_at
        elsif proto.start_in.to_i > 0
            DateTime.now.utc + proto.start_in.days
        else
        	nil
        end
	end

    def self.expires_at_calc proto
        if proto.expires_at
            proto.expires_at
        elsif proto.expires_in.to_i > 0
            DateTime.now.utc + proto.days
        else
        	nil
        end
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
#


