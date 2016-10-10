class Redeem
	extend MoneyHelper

		#   -------------

	def self.complete(gift: nil, redemption: nil, qr_code: nil, ticket_num: nil, server: nil, client_id: nil, callback_params: nil)
		puts "Redeem.complete"

			# set data and reject invalid submissions
		if !redemption.kind_of?(Redemption)
			return { 'success' => false, "response_text" =>  "Redemption not found", "response_code" => 'INVALID_INPUT'}
		end

		if redemption.status == 'done'
			resp = redemption.response
			resp['success'] = true
			resp['redemption'] = redemption
			resp['gift'] = redmeption.gift
			return resp
		end

		if !gift.kind_of?(Gift)
			gift = redemption.gift
			if !gift.kind_of?(Gift)
				return { 'success' => false, "response_text" =>  "Gift not found", "response_code" => 'INVALID_INPUT'}
			end
		end

		if client_id.kind_of?(Client)
			client_id = client_id.id
		end
		request_hsh = { gift_id: gift.id, redemption_id: redemption.id, qr_code: qr_code, ticket_num: ticket_num, server: server, client_id: client_id }
		puts request_hsh.inspect

		merchant = redemption.merchant

			# confirm the specfic data is present
		if redemption.r_sys == 3 && ticket_num.blank?
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "Ticket Number not found" }
		end
		if redemption.r_sys == 5
			if callback_params.blank? && qr_code.blank?
				return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "QR Code not found" }
			end
		end

		#   -------------

			# Let's process the redemption
		case redemption.r_sys
		when 1   # V1
			# there is no POS for V1 - always works
			pos_obj, resp = v1_redemption(server=nil, redemption, gift)
		when 2   # V2
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "Give code #{redemption.token} to server to redeem." }
		when 3   # OMNIVORE
			pos_obj, resp = omnivore_redemption( gift, ticket_num, redemption.amount, merchant )
		when 4   # PAPER
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "Give Voucher ID to server to redeem." }
		when 5   # ZAPPER
			if callback_params.present?
				pos_obj, resp = zapper_callback_redemption( gift, qrcode, amount, redemption )
			else
				pos_obj, resp = zapper_sync_redemption( gift, callback_params, redemption )
			end
		else
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "Unsupported redemption type (#{redemption.r_sys})" }
		end

		#   -------------

			# update the redemption and the gift

		if !pos_obj.success?
				# failure is in the response already
			resp['success'] = false
			resp['redemption'] = redemption
			resp['gift'] = gift
			return resp
		else
			# set the actual amount, gift_next_value, gift/redemption statuses, redemption.req_json , redemption.resp_json
			redemption.client_id = client_id if redemption.client_id.nil?
			redemption.resp_json = pos_obj.response
			redemption.ticket_id = pos_obj.ticket_id
			redemption.status = 'done'
			if pos_obj.applied_value != redemption.amount
					# redemption needs to be re-calculated
				if redemption.amount < pos_obj.applied_value
					OpsTwilio.text_devs(msg: "POS Redemption HIGHER than redemption amount #{redemption.id}")
				end
				redemption.amount = pos_obj.applied_value
				redemption.gift_next_value = (redemtion.gift_prev_value - redemption.amount)
				if redemption.gift_next_value < 0
					redemption.gift_next_value = 0
					OpsTwilio.text_devs(msg: "Gift has been OVER-REDEEEMED #{redemption.id}")
				end
			end
			gift.redemptions << redemption
			if (redemption.gift_next_value <= 0)
				gift.status = 'redeemed'
			end
			gift.detail = redemption.msg + '\n' + gift.detail.to_s
			gift.balance = redemption.gift_next_value
			if gift.save
				Resque.enqueue(GiftAfterSaveJob, gift.id)
				resp = redemption.response
				resp['success'] = true
				resp['redemption'] = redemption
				resp['gift'] = redmeption.gift
				return resp
			else
				# gift / redemption didnt save , but charge went thru
				mg =  "REDEEM - 500 Internal - POS SUCCESS / DB FAIL redemption #{redemption.id} failed \nPOS-#{pos_obj.inspect}\n Gift-#{gift.errors.messages.inspect}\n REDEEM-redemption.errors.messages.inspect}\n"
				puts mg
				OpsTwilio.text_devs(msg: mg)
				# what to do here  ??

			end

		end


	end

		#   -------------

	def self.v1_redemption(server=nil, redemption, gift)
			# OpsInternalPos is defined at bottom of this file
		v1_pos_obj = OpsInternalPos.new(redemption, gift)
		redemption.req_json = v1_pos_obj.make_request_hsh
		return [ v1_pos_obj, v1_pos_obj.response ]
	end

	def self.omnivore_redemption(gift, ticket_num, amount, merchant)
		# gift.pos_redeem(ticket_num, pos_merchant_id, tender_type_id, merchant_id, amount)
		omnivore = Omnivore.init_with_gift( gift, ticket_num, amount, nil, merchant )
		redemption.req_json = omnivore.make_request_hsh
		resp = omnivore.redeem
		return [ omivore, resp ]
	end

	def self.zapper_sync_redemption( gift, qrcode, amount, redemption )
		zapper_request = OpsZapper.make_request_hsh( gift, qrcode, amount, redemption.hex_id )
		redemption.req_json = zapper_request
		zapper_obj = OpsZapper.new( zapper_request )
		resp = zapper_obj.redeem_gift
		return [ zapper_obj, resp ]
	end

	def self.zapper_callback_redemption( gift, callback_params, redemption )
		zapper_request = r.request
        zapper_request['redemption_id'] = r.hex_id
        zapper_obj = OpsZapper.new( zapper_request )
        zapper_obj.apply_callback_response(callback_params)
        return [ zapper_obj, zapper_obj.response ]
	end

		#   -------------


	def self.start(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant)
		puts "Redeem.start"

			# set data and reject invalid submissions
		return { 'success' => false, "response_text" =>  "Gift not found", "response_code" => 'INVALID_INPUT'} unless gift.kind_of?(Gift)
		api = "SCRIPT" if api.nil?
		# OpsTwilio.text_devs(msg: "gift #{gift.id} notify has no client_id") if client_id.nil?
		if client_id.kind_of?(Client)
			client_id = client_id.id
		end
		request_hsh = { loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of }
		puts request_hsh.inspect

		#   -------------

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

			# V1 & POS & Zapper redemption currently make their own redemptiosn
		if (r_sys == 1) || (r_sys == 3) || (r_sys == 5)
			gift.notify
			return { 'success' => true, "gift" => gift, "response_code" => gift.token, "response_text" => nil }
		end
				# DO I NEED TO CONFIRM THAT GIFT IS GOOD HERE ?
		if merchant.mode != 'live'
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "#{merchant.name} is not currently live" }
		else
			gift.merchant_id = loc_id
		end

		#   -------------

		redeems = Redemption.where(gift_id: gift.id, active: true, status: ['done', 'pending']).order(created_at: :desc)

			# check for existing pending redemptions
		already_have_one = nil
		redeems.each do |redeem|
			if redeem.status == 'pending'
				if redeem.stale?
					# expire and skip
					next
				else
					if (gift.balance == redeem.amount) || (gift.original_value == redeem.amount)
						# full redemption - no more redmeptions allowed
						puts "Redemption FOUND #{redemption.id}"
						already_have_one = response(redeem, gift)
						break
					else
						# pending exists but we could make another, what are criteria ?
						puts "Redemption FOUND (partial) #{redemption.id}"
						already_have_one = response(redeem, gift)
						break
					end
				end
			end
		end
		return already_have_one unless already_have_one.nil?

		#   -------------

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

		#   -------------

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

		#   -------------

			# initialize a Redemption record
		redemption = Redemption.new( gift_id: gift.id, type_of: Redemption.convert_r_sys_to_type_of(merchant.r_sys), r_sys: merchant.r_sys,
			amount: amount, gift_prev_value: gift_prev_value, gift_next_value: gift_next_value, status: 'pending',
			client_id: client_id, merchant_id: merchant.id, start_req: request_hsh )

			# save the data
		if redemption.save
			puts "Redemption SAVED #{redemption.id}"
			return response(redemption, gift)
		else
			puts redemption.inspect
			return { 'success' => false, "response_code" => "INVALID_INPUT", "response_text" =>  redemption.errors.full_messages }
		end
	end

		#   -------------

	def self.response redemption, gift
		puts redemption.inspect
		gift.token = redemption.token if gift.token != redemption.token
		gift.new_token_at = redemption.new_token_at if gift.new_token_at != redemption.new_token_at
		redemption.start_res = {'response_code' => "PENDING", "response_text" => success_hsh(redemption) }
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

		#   -------------    	OpsInternalPos DEFINITION    	-------------

OpsInternalPos = Struct.new(:redemption, :gift, :server) do

	def success?
		true
	end

	def ticket_id
		server
	end

	def applied_value
		redemption.amount
	end

		#   -------------

	def response
		redemption.generic_response
	end

	def make_request_hsh
		{
			"server" => server,
            "gift_card_id" => gift.hex_id,
            "value" => redemption.amount,
            "ccy" => redemption.ccy,
            'redemption_id' => redemption.hex_id
        }
	end

end














