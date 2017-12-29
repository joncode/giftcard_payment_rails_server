class Redeem
	extend MoneyHelper

	def self.change_amount(redemption, new_amount)
		return redemption if redemption.status != 'pending'
		if new_amount.to_i < redemption.amount
			redemption.update(amount: new_amount, gift_next_value: (redemption.gift_prev_value - new_amount))
			return redemption
		else
				# do not change , return the lower applied_amount
			return redemption
		end
	end

	def self.set_gift_current_balance_and_status(gift)
		set_balance(gift)
		set_gift_current_status(gift)
	end

	def self.set_balance(gift)
		total_redeemed_amt = gift.complete_redemptions.reload.map(&:amount).sum
		gift.balance = gift.original_value - total_redeemed_amt
	end

	def self.set_gift_current_status(gift)
		return 'BAD STATUS' unless ['incomplete', 'open', 'notified', 'redeemed'].include?(gift.status)

		if gift.balance == 0
			if gift.complete_redemptions.length > 0
				total_redeemed_amt = gift.complete_redemptions.map(&:amount).sum
				unless total_redeemed_amt < gift.original_value
					return gift.status = 'redeemed'
				end
			end
		end

		if gift.balance != gift.original_value
			gift.status = 'notified'
		elsif gift.notified_at.present? && gift.receiver_id
			gift.status = 'notified'
		elsif gift.receiver_id
			gift.status = 'open'
		else
			gift.status = 'incomplete'
		end
	end


#   -------------   API SURFACE METHODS

	# Redeem.partial_redeem_redemption(redemption: r, amount: amt)

	def self.partial_redeem_redemption(redemption: , amount: )
		if redemption.amount < amount || redemption.status != 'pending'
			raise "Incorrect Redemption amount attempted"
		end
		gift = redemption.gift
		set_gift_current_balance_and_status(gift)
		gift_previous_value = gift.balance
		gift_next_value = gift_previous_value - amount
        # reset the redemption
        # 1. create a new sync redemption for the adjusted amount
        new_redemption = Redemption.new(gift_id: redemption.gift_id,
        	amount: amount,
        	ticket_id: redemption.paper_id,
        	start_req: { "loc_id" => redemption.merchant_id, "amount" => amount, "api" => redemp, "type_of" => "V2" },
        	type_of: 1,
        	merchant_id: redemption.merchant_id,
        	status: 'done',
        	gift_prev_value: gift_previous_value,
        	gift_next_value: gift_next_value
    	)
        if new_redemption.save
	        # 2. adjust the balance on the gift
	        set_gift_current_balance_and_status(gift)
	        gift.save
	        # 3. adjust the prev and next values on the paper redemption that is still pending
	        redemption.gift_prev_value = gift_next_value
	        redemption.amount = redemption.amount - amount
        	redemption.status = 'done' if redemption.gift_next_value <= 0
	        redemption.save
	        redemption
        	return { 'success' => true, "response_code" => 'REDEEMED', "response_text" => "Redemption partially redeemed" }
		else
			return { 'success' => false, "response_code" => 'INVALID_INPUT', "response_text" => new_redemption.errors.full_messages }
		end
	end

	def self.start_redeem(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant, sync: false)
		if gift.r_sys == 8
			api = api.gsub('start_redemption', 'start_apply_redemption')
			start_apply(gift: gift, loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of, sync: sync)
		else
			start(gift: gift, loc_id: loc_id, amount: amount, client_id: client_id, api: api)
		end
	end

	def self.complete_redeem(gift: nil, redemption: nil, qr_code: nil, ticket_num: nil, server: nil, client_id: nil, callback_params: nil)
		gift = gift || redemption.gift
        if gift.r_sys == 8
        	if pos_obj = redemption.print_queues.where(status: 'done').last
            	complete(redemption: redemption, gift: gift, pos_obj: pos_obj, client_id: client_id)
            elsif pos_obj = redemption.print_queues.where(status: ['delivered', 'queue']).last
            	# do nothing just wait
            else # expired or cancel
            	# should we make another queue ?
            end
        else
            apply_and_complete(gift: gift, redemption: redemption, qr_code: qr_code, ticket_num: ticket_num, server: server, client_id: client_id, callback_params: callback_params)
        end
	end

	def self.start_apply(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant, sync: false)
		rs = start(gift: gift, loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of, sync: sync)
	    if rs['success']
	        apply(gift: rs['gift'], redemption: rs['redemption'], client_id: client_id)
	    else
	    	rs
	    end
	end

	def self.apply_and_complete(gift: nil, redemption: nil, qr_code: nil, ticket_num: nil, server: nil, client_id: nil, callback_params: nil)
		ra = apply(gift: gift, redemption: redemption, qr_code: qr_code, ticket_num: ticket_num, server: server, client_id: client_id, callback_params: callback_params)

		if ra['success']
	        complete(redemption: ra['redemption'], gift: ra['gift'],  pos_obj: ra['pos_obj'], client_id: client_id)
	    else
	    	ra
	    end
	end

#   -------------

	def self.apply(gift: nil, redemption: nil, qr_code: nil, ticket_num: nil, server: nil, client_id: nil, callback_params: nil)
		puts "REDEEM.apply RequestHsh\n"

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

		client_id = client_id.id if client_id.kind_of?(Client)

		request_hsh = { gift_id: gift.id, redemption_id: redemption.id, qr_code: qr_code,
			ticket_num: ticket_num, server: server, client_id: client_id, callback: callback_params }
		puts "Redeem - APPLY - " + request_hsh.inspect

		merchant = redemption.merchant

			# confirm the specfic data is present
		if redemption.r_sys == 3 && ticket_num.blank?
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Ticket Number not found" }
		end
		if redemption.r_sys == 5   # zapper sync / async
			if callback_params.blank? && qr_code.blank?   # both blank we have no unique data
				return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
					"response_text" =>  "QR Code not found" }
			elsif callback_params.blank? && !qr_code.blank?
				# validate that QR code is a URL
				unless UrlValidate.uri?(qr_code)
					return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
						"response_text" =>  "QR Code is invalid, please scan again" }
				end
			end
		end

		if redemption.status != 'pending'
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
						"response_text" =>  "Redemption is #{redemption.status}" }
		end

		#   -------------

			# Let's get the current gift balance and set the redemption correctly
		available_balance = gift.balance

		if available_balance == 0
			redemption.remove_pending( 'cancel',
							{ 'response_code' => 'SYSTEM_CANCEL', 'response_text' => "API - Redeem.rb - Gift is already redeemed" })
			return { 'success' => false, "response_code" => 'ALREADY_REDEEMED',
					"response_text" => "Gift at #{gift.provider_name} has already been redeemed" }
		end


		if (redemption.amount > available_balance) || (redemption.gift_prev_value != available_balance)
				# redemption must be adjusted
			redemption.amount = available_balance if (redemption.amount > available_balance)
			redemption.gift_prev_value = available_balance
			redemption.gift_next_value = available_balance - redemption.amount
			hsh = redemption.start_res
			hsh['updated'] = { "previous_gift_balance"=>redemption.gift_prev_value, "amount_applied"=>redemption.amount, "remaining_gift_balance"=>redemption.gift_next_value }
			redemption.start_res = hsh
			redemption.save
		end

		#   -------------


			# Let's process the redemption
		case redemption.r_sys
		when 1   # V1
			# there is no POS for V1 - always works
			pos_obj, resp = internal_redemption( redemption, gift, server )
		when 2   # V2
			pos_obj, resp = internal_redemption( redemption, gift, server )
		when 3   # OMNIVORE
			pos_obj, resp = omnivore_redemption( redemption, gift, ticket_num, redemption.amount, merchant )
		when 4   # PAPER
			pos_obj, resp = internal_redemption( redemption, gift, "#{ticket_num}-#{server}" )
		when 5   # ZAPPER
			if callback_params.present?
				pos_obj, resp = zapper_callback_redemption( redemption, gift, callback_params )
			else
				pos_obj, resp = zapper_sync_redemption( redemption, gift, qr_code, redemption.amount )
			end
		when 6	# ADMIN
			pos_obj, resp = internal_redemption( redemption, gift, server )
		when 7  # Clover
			pos_obj, resp = internal_redemption( redemption, gift, "#{ticket_num}-#{server}" )
		when 8  # Epson
			pos_obj, resp = epson_redemption( redemption, gift )
		else
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" =>  "Unsupported redemption type (#{redemption.r_sys})" }
		end


		# Print the redemption if the merchant is on Epson
		if redemption.merchant.r_sys == 8
			# and if the redemption's r_sys isn't also Epson (since that queues a print job above)
			if redemption.r_sys != 8
				puts "[model Redeem :: apply]  Merchant is on Epson; printing the redemption."
				pq = PrintQueue.queue_redemption(redemption)
				puts "[model Redeem :: apply]  queued redemption: #{pq.inspect}"
			end
		end


		# redemption.save
		hsh = { 'success' => true, 'pos_obj' => pos_obj, 'gift' => gift, 'redemption' => redemption }
		puts hsh.inspect
		return hsh
	end


#   -------------

	def self.epson_redemption(redemption, gift)
		# is there already a print queue item - pending or printed ? for the redemption
		print_queue = PrintQueue.queue_redemption(redemption)
		redemption.request = print_queue.make_request_hsh
		redemption.save
		return [ print_queue, print_queue.response ]
	end

	def self.internal_redemption(redemption, gift, server)
			# OpsIomApiPos is defined at bottom of this file
		v1_pos_obj = OpsIomApiPos.new(redemption, gift, server)
		redemption.request = v1_pos_obj.make_request_hsh
		redemption.save
		return [ v1_pos_obj, v1_pos_obj.response ]
	end

	def self.omnivore_redemption(redemption, gift, ticket_num, amount, merchant)
		# gift.pos_redeem(ticket_num, pos_merchant_id, tender_type_id, merchant_id, amount)
		# omnivore = Omnivore.init_with_gift( gift, ticket_num, amount, nil, merchant )
		omnivore = Omnivore.init_with_redemption( redemption, ticket_num, merchant )
		redemption.request = omnivore.make_request_hsh
		redemption.save
		resp = omnivore.redeem
		return [ omnivore, resp ]
	end

	def self.zapper_sync_redemption(redemption, gift, qr_code, amount )
		zapper_request = OpsZapper.make_request_hsh( gift, qr_code, amount, redemption )
		redemption.request = zapper_request
		redemption.save
		zapper_obj = OpsZapper.new( zapper_request )
		resp = zapper_obj.redeem_gift
		return [ zapper_obj, resp ]
	end

	def self.zapper_callback_redemption(redemption, gift, callback_params )
		zapper_request = redemption.request
        zapper_obj = OpsZapper.new( zapper_request )
        zapper_obj.apply_callback_response(callback_params)
        return [ zapper_obj, zapper_obj.response ]
	end


#   -------------


	def self.complete(redemption: nil, gift: nil, pos_obj: nil, client_id: nil)
		puts "Redeem.complete"
		puts "POSObject = " + pos_obj.inspect

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
		puts "-------------------------------------"
		puts "REDEEM.complete RequestHsh\n"
		request_hsh = { pos_obj: pos_obj.inspect, gift_id: gift.id, redemption_id: redemption.id, client_id: client_id }
		puts request_hsh.inspect
		puts redemption.inspect
		puts gift.inspect
		puts "-------------------------------------"


		#   -------------

			# update the redemption and the gift
		if pos_obj.success?
			puts "SUCCESS POS_OBJECT"
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

			if pos_obj.response['response_text'].kind_of?(Hash) && !pos_obj.response['response_text'][:msg].blank?
				new_detail = pos_obj.response['response_text'][:msg]
			else
				new_detail = redemption.msg
			end
			gift.detail = new_detail + '. ' + gift.detail.to_s
		else
			puts "FAILURE POS_OBJECT"
			# why is there a failure
			# must remove the redemption and allow for a new one
				# must release the hold on the gift card value
			# must set the status of the redemption to something reasonable
			redemption.amount = 0
			redemption.status = 'failed'
		end

		redemption.client_id = client_id if redemption.client_id.nil?
		redemption.ticket_id = pos_obj.ticket_id
		r_hsh = { "response_code" => pos_obj.response['response_code'], "success" => pos_obj.response['success'],
			 "response_text" => pos_obj.response['response_text'], 'api' => pos_obj.response['api'] }
		redemption.response = r_hsh

		resp = pos_obj.response
		resp['success'] = pos_obj.success?
		resp['pos_obj'] = pos_obj

		puts "Saving redemption & gift resp = #{resp.inspect}"

		if redemption.save
			set_gift_current_balance_and_status(gift)
			if gift.save
				puts "Redeem.complete(357) Save success"
				Resque.enqueue(GiftRedeemedEvent, gift.id, redemption.id) if pos_obj.success? && gift.status == 'redeemed'
				Resque.enqueue(GiftAfterSaveJob, gift.id) if pos_obj.success?
			else
				mg =  "REDEEM(360) - 500 Internal - GIFT SAVED FAILED #{gift.errors.messages}"
				puts mg
				resp['system_errors'] = gift.errors.full_messages
			end
			Resque.enqueue(RedemptionNotificationJob, redemption.id, 'failed') if redemption.status == 'failed'
			Resque.enqueue(RedemptionNotificationJob, redemption.id, 'done') if redemption.status == 'done'
			Resque.enqueue(PushJob, nil, 'redemption_complete', redemption.id) if redemption.status == 'done'
		else
			# gift / redemption didnt save , but charge went thru
			mg =  "REDEEM(369) - 500 Internal - POS SUCCESS / DB FAIL redemption"
			puts mg
			mg = " #{redemption.id} failed \nPOS-#{pos_obj.inspect}\nREDEEM-#{redemption.errors.messages.inspect}\n"
			puts mg
			# OpsTwilio.text_devs(msg: mg)
			resp['system_errors'] = redemption.errors.full_messages
			# what to do here  ??
				# pos has returned and processed a value , but our system is not storing due likely to bug
				# how to return to customer without issue , while getting bug fixed and data sorted immediately

		end

		resp['redemption'] = redemption
		resp['gift'] = gift
		return resp
	end


#   -------------


	def self.start(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant, sync: false)
		puts "REDEEM.start RequestHsh\n"
		request_hsh = { loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of }
		puts request_hsh.inspect

		  # -------------  SAFE DATA

			# set data and reject invalid submissions
		if !gift.kind_of?(Gift)
			return { 'success' => false, "response_text" =>  "Gift not found", "response_code" => 'INVALID_INPUT'}
		elsif !gift.notifiable?
			if gift.status == 'redeemed'
				return { 'success' => false, "response_code" => 'ALREADY_REDEEMED',
					"response_text" => "Gift #{gift.token} at #{gift.provider_name} has already been redeemed" }
			else
				return { 'success' => false, "response_code" => 'NOT_REDEEMABLE',
					"response_text" =>  "Gift cannot be redeemed (#{gift.status})" }
			end
		end
		api = "SCRIPT" if api.nil?
		if client_id.kind_of?(Client)
			client_id = client_id.id
		end

		  # -------------  MULTI-REDEMPTION

			# set the redemption location - and adjust the gift.merchant_id
		loc_id = loc_id.to_i
		loc_id = gift.merchant_id if loc_id == 0

		if loc_id != gift.merchant_id
			merchant = Merchant.find(loc_id)
			gift.merchant = merchant
		else
			merchant = gift.merchant
		end

		  # -------------

		if gift.brand_card
			if gift.original_value != amount
				puts "Setting the amount to #{gift.original_value} from #{amount}"
				amount = gift.original_value
			end
		end

		  # -------------

		type_of = type_of.to_sym

		if type_of == :merchant
			r_sys = merchant.r_sys
		else
			r_sys = Redemption.convert_type_of_to_r_sys(type_of)
		end

		if type_of == :paper
				# re-issuing a paper cert
			redeems = Redemption.current_paper(gift)
			if redeems.length > 1
				return { 'success' => true, "gift" => gift, "redemption" => redeems.first }
			elsif redeems.length == 1
				return { 'success' => true, "gift" => gift, "redemption" => redeems.first }
			else
				# no other paper redemption , move on
			end
		end

		if type_of != :paper
				# check for existing pending redemptions
					# paper does not issue a non-paper redemption
			already_have_one = nil
			redeems = Redemption.get_all_live_redemptions(gift, r_sys)
			already_have_one = Redemption.current_pending_redemption(gift, redeems, r_sys)
			if already_have_one.present?
				if already_have_one.r_sys == 4 # paper gift
						 # paper gifts can be re-drawn with this code
					if api.present? && api.match(gift.hex_id)
						return { 'success' => true, "gift" => gift, "redemption" => already_have_one }
					else
						if r_sys == 4
							return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
								"response_text" => "Gift has been converted to a Paper Gift Certificate." }
						end
					end
				else
					if sync
						if already_have_one.merchant_id == gift.merchant_id
							already_have_one.remove_pending( 'cancel',
								{ 'response_code' => 'SYSTEM_CANCEL', 'response_text' => "API - Redeem.rb - Removed for next redemption via #{api}" })
						end
					else
						return response(already_have_one, gift)
					end
				end
			end
		end
		puts "ONTO VALUE LEVEL Balance: #{gift.balance} - Status: #{gift.status}"

		  # -------------
		set_gift_current_balance_and_status(gift)

		puts "Balance: #{gift.balance} - Status: #{gift.status}"

		if amount.nil?
			amount = gift.balance
		else
			amount = amount.to_i
		end

		if !amount.kind_of?(Integer)
			return { 'success' => false, "response_code" => 'INVALID_INPUT',
				"response_text" => "Amount #{amount} is not denominated in #{CCY[gift.ccy]['subunit'].pluralize(2)}" }
		# elsif amount == 0
		# 	return { 'success' => false, "response_code" => 'INVALID_INPUT',
		# 		"response_text" => "Gift Amount (#{display_money(cents: amount, ccy: gift.ccy)}) is not a redeemable value" }
		elsif amount == gift.balance
			amount = gift.balance
			gift_prev_value = gift.balance
			gift_next_value = 0
		elsif amount < gift.balance
			amount = amount
			gift_prev_value = gift.balance
			gift_next_value = (gift.balance - amount)
		elsif amount > gift.balance
			return { 'success' => false, "response_code" =>  'INVALID_INPUT',
				"response_text" => "The amount (#{display_money(cents: amount, ccy: gift.ccy)}) received is more than the current value on the gift (#{display_money(cents: gift.balance, ccy: gift.ccy)})" }
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
		# available_amt = value_amt - reserved_amt
		if amount > value_amt
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
				"response_text" => "The amount (#{display_money(cents: amount, ccy: gift.ccy)}) received is more than the remaining balance on the gift of #{ display_money(cents: value_amt, ccy: gift.ccy) }" }
		# elsif amount > available_amt
		# 	return { 'success' => false, "response_code" => "NOT_REDEEMABLE",
		# 		"response_text" => "Due to pending redemptions, the amount you entered is more than current available balance #{display_money(cents: available_amt, ccy: gift.ccy)} " }
		end

		  # -------------

			# initialize a Redemption record
		redemption = Redemption.new( gift_id: gift.id, type_of: Redemption.convert_r_sys_to_type_of(r_sys), r_sys: r_sys,
			amount: amount, gift_prev_value: gift_prev_value, gift_next_value: gift_next_value, status: 'pending',
			client_id: client_id, merchant_id: merchant.id, start_req: request_hsh )

			# save the data
		if redemption.save
			puts "Redemption SAVED #{redemption.inspect}"
			return response(redemption, gift)
		else
			puts redemption.inspect
			return { 'success' => false, "response_code" => "INVALID_INPUT",
				"response_text" =>  redemption.errors.full_messages, 'gift' => gift, 'redemption' => redemption }
		end
	end

#   -------------

	def self.response redemption, gift
		gift.status = 'notified'
		gift.token = redemption.token
		gift.new_token_at = redemption.new_token_at
		gift.rec_client_id = redemption.client_id if gift.rec_client_id.nil?
		set_gift_current_balance_and_status(gift)
		redemption.start_res = { 'response_code' => "PENDING", "response_text" => redemption.success_hsh }
		gift.redemptions << redemption
		if gift.save
			Resque.enqueue(GiftAfterSaveJob, gift.id)
		end
		return { 'success' => true, 'redemption' => redemption, 'gift' => gift, 'response_code' => "PENDING",
			"response_text" => redemption.success_hsh, 'token' => redemption.token }
	end


end
















