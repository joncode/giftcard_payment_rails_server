class Redeem
	extend MoneyHelper

#   -------------

	def self.start(gift: nil, loc_id: nil, amount: nil, client_id: nil, api: nil, type_of: :merchant)
		puts "Redeem.start"

			# set data and reject invalid submissions
		return { 'success' => false, "response_text" =>  "Gift not found", "response_code" => 'INVALID_INPUT'} unless gift.kind_of?(Gift)
		api = "SCRIPT" if api.nil?
		# OpsTwilio.text_devs(msg: "gift #{gift.id} notify has no client_id") if client_id.nil?
		request_hsh = { loc_id: loc_id, amount: amount, client_id: client_id, api: api, type_of: type_of }
		puts request_hsh.inspect

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
		Redemption.where(gift_id: gift.id, active: true, status: ['done', 'pending']).each do |r|
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

			# set the redemption location - and adjust the gift.merchant_id
		loc_id = loc_id.to_i
		loc_id = gift.merchant_id if loc_id == 0

		if loc_id != gift.merchant_id
			merchant = Merchant.find(loc_id)
		else
			merchant = gift.merchant
		end
				# DO I NEED TO CONFIRM THAT GIFT IS GOOD HERE ?
		if merchant.mode != 'live'
			return { 'success' => false, "response_code" => "NOT_REDEEMABLE", "response_text" =>  "#{merchant.name} is not currently live" }
		else
			gift.merchant_id = loc_id
		end
		if type_of == :merchant
			r_sys = merchant.r_sys
		else
			r_sys = Redemption.convert_type_of_to_r_sys(type_of)
		end

#   -------------

			# initialize a Redemption record
		redemption = Redemption.new( gift_id: gift.id, type_of: Redemption.convert_r_sys_to_type_of(merchant.r_sys), r_sys: merchant.r_sys,
			amount: amount, gift_prev_value: gift_prev_value, gift_next_value: gift_next_value, status: 'pending',
			client_id: client_id, merchant_id: merchant.id, req_json: request_hsh )
		redemption.resp_json = {'response_code' => "PENDING", "response_text" => success_hsh(redemption) }

			# save the data
		if redemption.save
			puts redemption.inspect
			gift.token = redemption.token
			gift.new_token_at = redemption.new_token_at
			gift.save
			Resque.enqueue(GiftAfterSaveJob, gift.id)
			return { 'success' => true, 'redemption' => redemption, 'gift' => gift, 'response_code' => "PENDING",
				"response_text" => success_hsh(redemption) }
		else
			puts redemption.inspect
			return { 'success' => false, "response_code" => "INVALID_INPUT", "response_text" =>  redemption.errors.full_messages }
		end
	end


	def self.success_hsh redemption
		{
            previous_gift_balance: redemption.gift_prev_value,
            amount_applied: redemption.amount,
            remaining_gift_balance: redemption.gift_next_value,
            msg: "Give code #{redemption.token} to your server"
		}
	end

end