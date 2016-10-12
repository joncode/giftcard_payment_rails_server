class Redeem
	extend MoneyHelper


#   -------------

	def self.apply(gift: nil, redemption: nil, qr_code: nil, ticket_num: nil, server: nil, client_id: nil, callback_params: nil)
		puts "Redeem.apply"

			# set data and reject invalid submissions
		if !redemption.kind_of?(Redemption)
			return { 'success' => false, "response_code" => 'INVALID_INPUT',
				"response_text" => "Redemption not found. Please contact support@itson.me" }
		end

		if redemption.status == 'done'
			resp = redemption.response
			resp['success'] = true
			resp['redemption'] = redemption
			resp['gift'] = redemption.gift
			resp['pos_obj'] = nil
			return resp
		end

		if !gift.kind_of?(Gift)
			gift = redemption.gift
			if !gift.kind_of?(Gift)
					# gift has been cancelled / deactivated
				return { 'success' => false, "response_code" => 'INVALID_INPUT',
					"response_text" =>  "Gift has been deactivated. Please contact support@itson.me" }
			end
		end

		if client_id.kind_of?(Client)
			client_id = client_id.id
		end
		puts "REDEEM.apply RequestHsh\n"
		request_hsh = { gift_id: gift.id, redemption_id: redemption.id, qr_code: qr_code,
			ticket_num: ticket_num, server: server, client_id: client_id }
		puts request_hsh.inspect

		merchant = redemption.merchant

			# confirm the specfic data is present
		if redemption.r_sys == 3 && ticket_num.blank?
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Ticket Number not found" }
		end
		if redemption.r_sys == 5
			if callback_params.blank? && (qr_code.blank? || callback_params.blank?)
				return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
					"response_text" =>  "QR Code not found" }
			end
		end

		#   -------------

			# Let's process the redemption
		case redemption.r_sys
		when 1   # V1
			# there is no POS for V1 - always works
			pos_obj, resp = internal_redemption( redemption, gift, server )
		when 2   # V2
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Give code #{redemption.token} to server to redeem." }
		when 3   # OMNIVORE
			pos_obj, resp = omnivore_redemption( redemption, gift, ticket_num, redemption.amount, merchant )
		when 4   # PAPER
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Give Voucher ID to server to redeem." }
		when 5   # ZAPPER
			if callback_params.present?
				pos_obj, resp = zapper_callback_redemption( redemption, gift, callback_params )
			else
				pos_obj, resp = zapper_sync_redemption( redemption, gift, qrcode, amount )
			end
		else
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Unsupported redemption type (#{redemption.r_sys})" }
		end
		redemption.save
		return { 'success' => true, 'pos_obj' => pos_obj, 'gift' => gift, 'redemption' => redemption }
	rescue => e
		mg = "RESCUE IN REDEEM.appply - 500 Internal - FAIL APPLY redemption\n "
		mg |=  " #{redemption.id} failed \n #{e.inspect} \nPOS-#{pos_obj.inspect}\n Gift-#{gift.errors.messages.inspect}\n\
			  REDEEM-#{redemption.errors.messages.inspect}\n"
		puts mg
		# OpsTwilio.text_devs(msg: mg)
		return { 'success' => false, "response_code" => "ERROR", 'system_errors' => e.inspect,
				"response_text" =>  "System Error, unable to apply redemption. Pease try again later" }
	end

	def self.complete(redemption: nil, gift: nil, pos_obj: nil, client_id: nil)
		puts "Redeem.complete"

			# set data and reject invalid submissions
		if pos_obj.nil? || !pos_obj.respond_to?(:applied_value)
			return { 'success' => false, "response_code" => 'INVALID_INPUT',
				"response_text" => "System unavailable, please retry in a minute."}
		end
		if !redemption.kind_of?(Redemption)
			return { 'success' => false, "response_code" => 'INVALID_INPUT',
				"response_text" => "Redemption not found. Please contact support@itson.me"}
		end
		if !gift.kind_of?(Gift)
			gift = redemption.gift
			if !gift.kind_of?(Gift)
					# gift has been cancelled / deactivated
				return { 'success' => false, "response_code" => 'INVALID_INPUT',
					"response_text" =>  "Gift has been deactivated. Please contact support@itson.me"}
			end
		end
		if client_id.kind_of?(Client)
			client_id = client_id.id
		end
		puts "REDEEM.complete RequestHsh\n"
		request_hsh = { pos_obj: pos_obj.inspect, gift_id: gift.id, redemption_id: redemption.id, client_id: client_id }
		puts request_hsh.inspect


		#   -------------

		redemption.client_id = client_id if redemption.client_id.nil?
			# update the redemption and the gift
		if pos_obj.success?
			# set the actual amount, gift_next_value, gift/redemption statuses, redemption.req_json , redemption.resp_json
			redemption.status = 'done'
			if pos_obj.applied_value != redemption.amount
					# redemption needs to be re-calculated
				if redemption.amount < pos_obj.applied_value
					OpsTwilio.text_devs(msg: "POS Redemption HIGHER than redemption amount #{redemption.id}")
				end
				redemption.amount = pos_obj.applied_value
				redemption.gift_next_value = (redemption.gift_prev_value - redemption.amount)
				if redemption.gift_next_value < 0
					redemption.gift_next_value = 0
					OpsTwilio.text_devs(msg: "Gift has been OVER-REDEEEMED #{redemption.id}")
				end
			end
			if (redemption.gift_next_value <= 0)
				gift.status = 'redeemed'
			end
			gift.detail = redemption.msg + '\n' + gift.detail.to_s

		else
			# why is there a failure
			# must remove the redemption and allow for a new one
				# must release the hold on the gift card value
			# must set the status of the redemption to something reasonable

			redemption.amount = 0
			redemption.status = 'failed'
			gift.balance = gift.balance + (redemption.gift_prev_value - redemption.gift_next_value)
			redemption.gift_next_value = redemption.gift_prev_value

		end

		resp = pos_obj.response
		resp['success'] = pos_obj.success?
		resp['pos_obj'] = pos_obj

		r_hsh = { "response_code" => pos_obj.response['response_code'], "success" => pos_obj.success?,
			 "response_text" => pos_obj.response['response_text'] }
		redemption.resp_json = r_hsh
		redemption.ticket_id = pos_obj.ticket_id

		# gift.redemptions << redemption
		if gift.save
			Resque.enqueue(GiftAfterSaveJob, gift.id) if pos_obj.success?
		else
			# gift / redemption didnt save , but charge went thru
			mg =  "REDEEM - 500 Internal - POS SUCCESS / DB FAIL redemption\
			 #{redemption.id} failed \nPOS-#{pos_obj.inspect}\n Gift-#{gift.errors.messages.inspect}\n\
			  REDEEM-#{redemption.errors.messages.inspect}\n"
			puts mg
			# OpsTwilio.text_devs(msg: mg)
			resp['system_errors'] = gift.errors.full_messages
			# what to do here  ??
				# pos has returned and processed a value , but our system is not storing due likely to bug
				# how to return to customer without issue , while getting bug fixed and data sorted immediately

		end

		resp['redemption'] = redemption
		resp['gift'] = gift
		return resp
	rescue => e
		mg =  "RESCUE IN REDEEM.complete - 500 Internal - POS SUCCESS / DB FAIL redemption\n"
		mg += " #{redemption.id} failed \n #{e.inspect} \nPOS-#{pos_obj.inspect}\n Gift-#{gift.errors.messages.inspect}\n\
			  REDEEM-#{redemption.errors.messages.inspect}\n"
		puts mg
		# OpsTwilio.text_devs(msg: mg)
		resp = pos_obj.response
		resp['success'] = pos_obj.success?
		resp['pos_obj'] = pos_obj
		resp['redemption'] = redemption.reload
		resp['gift'] = gift.reload
		resp['system_errors'] = e.inspect
		return resp
	end

#   -------------

	def self.internal_redemption(redemption, gift, server)
			# OpsInternalPos is defined at bottom of this file
		v1_pos_obj = OpsInternalPos.new(redemption, gift, server)
		redemption.req_json = v1_pos_obj.make_request_hsh
		return [ v1_pos_obj, v1_pos_obj.response ]
	end

	def self.omnivore_redemption(redemption, gift, ticket_num, amount, merchant)
		# gift.pos_redeem(ticket_num, pos_merchant_id, tender_type_id, merchant_id, amount)
		# omnivore = Omnivore.init_with_gift( gift, ticket_num, amount, nil, merchant )
		omnivore = Omnivore.init_with_redemption( redemption, ticket_num, merchant )
		redemption.req_json = omnivore.make_request_hsh
		resp = omnivore.redeem
		return [ omnivore, resp ]
	end

	def self.zapper_sync_redemption(redemption, gift, qrcode, amount )
		zapper_request = OpsZapper.make_request_hsh( gift, qrcode, amount, redemption.hex_id )
		redemption.req_json = zapper_request
		zapper_obj = OpsZapper.new( zapper_request )
		resp = zapper_obj.redeem_gift
		return [ zapper_obj, resp ]
	end

	def self.zapper_callback_redemption(redemption, gift, callback_params )
		zapper_request = r.request
        zapper_request['redemption_id'] = r.hex_id
        zapper_obj = OpsZapper.new( zapper_request )
        zapper_obj.apply_callback_response(callback_params)
        return [ zapper_obj, zapper_obj.response ]
	end


#   -------------


	def self.start(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant, sync: false)
		puts "REDEEM.start RequestHsh\n"
		request_hsh = { loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of }
		puts request_hsh.inspect

			# set data and reject invalid submissions
		if !gift.kind_of?(Gift)
			return { 'success' => false, "response_text" =>  "Gift not found", "response_code" => 'INVALID_INPUT'}
		end
		api = "SCRIPT" if api.nil?
		if client_id.kind_of?(Client)
			client_id = client_id.id
		end

		  # -------------

			# set the redemption location - and adjust the gift.merchant_id
		loc_id = loc_id.to_i
		loc_id = gift.merchant_id if loc_id == 0

		if loc_id != gift.merchant_id
			merchant = Merchant.find(loc_id)
		else
			merchant = gift.merchant
		end

		if type_of == :merchant
			r_sys = merchant.r_sys
		else
			r_sys = Redemption.convert_type_of_to_r_sys(type_of)
		end

			# V1 & POS & Zapper redemption currently make their own redemptions
			# if sync is true it means this method is used to create the redemption for ALL R-sys
			# otherwise just notify the gift and send it down
		unless sync
			if (r_sys == 1) || (r_sys == 3) || (r_sys == 5)
				gift.notify
				return { 'success' => true, "gift" => gift, "response_code" => gift.token, "response_text" => nil }
			end
		end

				# DO I NEED TO CONFIRM THAT GIFT IS GOOD HERE ?
		if merchant.mode != 'live'
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" => "#{merchant.name} is not currently live" }
		else
			gift.merchant_id = loc_id
		end

		  # -------------


			# check for existing pending redemptions
		already_have_one = nil
		redeems = Redemption.get_all_live_redemptions(gift)
		already_have_one = Redemption.current_pending_redemption(gift, redeems)
		if already_have_one.present?
			return response(redeem, gift)
		end

		  # -------------

		amount = gift.balance if amount.nil?
		if !amount.kind_of?(Integer)
			return { 'success' => false, "response_code" => 'INVALID_INPUT',
				"response_text" => "Amount #{amount} is not denominated in #{CCY[gift.ccy]['subunit'].pluralize(2)}" }
		elsif amount == gift.balance
			gift_prev_value = gift.balance
			amount = gift.balance
			gift_next_value = 0
		elsif amount < gift.balance
			amount = amount
			gift_prev_value = gift.balance
			gift_next_value = (gift.balance - amount)
		elsif amount > gift.balance
			return { 'success' => false, "response_code" =>  'INVALID_INPUT',
				"response_text" => "The amount you entered is more than the current balance on the gift of #{display_money(cents: gift.balance, ccy: gift.ccy)}" }
		end

		  # -------------

			# confirm that the gift has available balance to redeem
		redeemed_amt = 0
		reserved_amt = 0
		redeems.each do |r|
			if r.status == 'done'
				redeemed_amt += r.amount
			elsif r.status == 'pending'
				reserved_amt += r.amount
			end
		end
		value_amt = gift.original_value - redeemed_amt
		available_amt = value_amt - reserved_amt
		if amount > value_amt
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" => "The amount you entered is more than the remaining balance on the gift of #{ display_money(cents: value_amt, ccy: gift.ccy) }" }
		elsif amount > available_amt
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" => "Due to pending redemptions, the amount you entered is more than current available balance #{display_money(cents: available_amt, ccy: gift.ccy)} " }
		end

		  # -------------

			# initialize a Redemption record
		redemption = Redemption.new( gift_id: gift.id, type_of: Redemption.convert_r_sys_to_type_of(r_sys), r_sys: r_sys,
			amount: amount, gift_prev_value: gift_prev_value, gift_next_value: gift_next_value, status: 'pending',
			client_id: client_id, merchant_id: merchant.id, start_req: request_hsh )

			# save the data
		if redemption.save
			puts "Redemption SAVED #{redemption.id}"
			return response(redemption, gift)
		else
			puts redemption.inspect
			return { 'success' => false, "response_code" => "INVALID_INPUT",
				"response_text" =>  redemption.errors.full_messages, 'gift' => gift, 'redemption' => redemption }
		end
	end

#   -------------

	def self.response redemption, gift
		puts redemption.inspect
		gift.status = 'notified'
		gift.notified_at = Time.now.utc if gift.notified_at.nil?
		gift.token = redemption.token if gift.token != redemption.token
		gift.new_token_at = redemption.new_token_at if gift.new_token_at != redemption.new_token_at
		gift.balance = redemption.gift_next_value
		redemption.start_res = { 'response_code' => "PENDING", "response_text" => success_hsh(redemption) }
		gift.redemptions << redemption
		if gift.save
			Resque.enqueue(GiftAfterSaveJob, gift.id)
		end
		return { 'success' => true, 'redemption' => redemption, 'gift' => gift, 'response_code' => "PENDING",
			"response_text" => success_hsh(redemption), 'token' => redemption.token }
	end

#   -------------

	def self.success_hsh redemption
		{
            previous_gift_balance: redemption.gift_prev_value,
            amount_applied: redemption.amount,
            remaining_gift_balance: redemption.gift_next_value,
            msg: "Give code #{redemption.token} to your server"
		}
	end

end
















