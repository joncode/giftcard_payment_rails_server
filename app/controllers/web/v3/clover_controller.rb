class Web::V3::CloverController < MetalCorsController
	include MoneyHelper

	before_action :authentication_clover, only: [ :redeem, :init ]



	# {"merchant_id"=>"J4Q1V4P5X0KS0", "application_key"=>"DXVQlmSoxvSo-lnKazbk2wTJkZtAIA-_Ot-gtFc--79Q", "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)"}

	# {"data"=>{"merchant"=>{"zip"=>"89101", "phone"=>"702-555-1212", "locale"=>"en_US", "state"=>"NV", "address1"=>"123 Mockingbird Lane", "address2"=>"Apt 2b",
	# "device_id"=>"abacc7fc-1f67-4cd5-9f9c-d0073b048fbf", "address3"=>"", "support_email"=>"dev@clover.com", "city"=>"Las Vegas", "currency"=>"USD", "id"=>"J4Q1V4P5X0KS0",
	# "time_zone"=>"Pacific Standard Time", "support_phone"=>"(000) 000-0000", "name"=>"ItsOnMe Test Merchant"}, "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)",
	# "serial_number"=>"b73f3293e5b33823"}, "format"=>"json", "controller"=>"web/v3/clover", "action"=>"init"}

 # {"data"=>{"merchant"=>{"zip"=>"89101", "phone"=>"702-555-1212", "website"=>"https://www.itson.me", "locale"=>"en_US", "state"=>"NV", "vat"=>false,
 # 	"address1"=>"123 Mockingbird Lane", "auth_token"=>"dec6d9ae-13d4-b71c-ce48-7d1617b036de", "address2"=>"Apt 2b", "device_id"=>"abacc7fc-1f67-4cd5-9f9c-d0073b048fbf",
 # 	"address3"=>"", "base_url"=>"https://apisandbox.dev.clover.com", "support_email"=>"dev@clover.com", "city"=>"Las Vegas", "currency"=>"USD", "id"=>"J4Q1V4P5X0KS0",
 # 	"time_zone"=>"Pacific Standard Time", "email"=>"richard1@rangerllt.comDEVtypecom.clover.account", "support_phone"=>"(000) 000-0000", "name"=>"ItsOnMe Test Merchant",
 # 	"account"=>"Account {name=ItsOnMe Test Merchant | richard1@rangerllt.com (DEV), type=com.clover.account}", "mid"=>"RCTST0000008099"},
 # 	"name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)", "serial_number"=>"b73f3293e5b33823"}}


	def init
		h = {}
		h = init_params[:merchant]
		h = h.deep_symbolize_keys
		h[:app_key] = request.headers['HTTP_X_APPLICATION_KEY']
		h[:serial_number] = init_params[:serial_number]
		h[:pos_merchant_id] = h[:id]
		mid = h[:id]
		h[:ccy] = h[:currency]

		if h[:email].kind_of?(String)
			if ' ' == h[:email].last
				h[:email] = h[:email][0 ... -1]
			end
			h[:email].to_s.gsub!(',','').gsub!('typecom.clover.account','').downcase!
		end

		if h[:phone].kind_of?(String)
			h[:phone].to_s.gsub!(/[^0-9]/,'')
		end

		if h[:support_phone].kind_of?(String)
			h[:support_phone].gsub!(/[^0-9]/,'')
		end

		puts "HERE is MERCHANT_HSH #{h.inspect}"

		o = OpsClover.new(h)
		puts o.inspect

		o.update_status

		case o.stoplight
		when :stop
			# this is a connection error
			fail_web({ err: "STOP", msg:  "Cannot Initialize Clover - Clover ID '#{mid}' not found"})
			@app_response[:data] = {
					code: 'STOP',
					message: "Cannot Initialize Clover - Clover ID '#{mid}' not found",
					client_id: SERVICE_NAME
				}
		when :live
			success({
					code: 'LIVE',
					message: "#{SERVICE_NAME} Tender Initialized - ready to redeem gift cards!",
					client_id: SERVICE_NAME,
					application_key: o.key
				})
		else #:support
			if o.status == :requested
				screen_msg = "#{SERVICE_NAME} team is setting up your merchant account."
			else
				screen_msg = "#{SERVICE_NAME} Merchant account requires support."
			end
			screen_msg = o.error if o.error.present?
			fail_web({ err: "SUPPORT", msg:  screen_msg})
			@app_response[:data] = {
					code: 'SUPPORT',
					message: screen_msg,
					client_id: SERVICE_NAME
				}
		end

		@app_response[:meta] = o.meta
		respond

	end
#### RANDOM RESPONSES
		# x = rand(2)

		# if x == 1
		# 	fail_web({ err: "NOT_FOUND", msg:  "Cannot Complete Initialization - Clover ID #{mid} not found"})
		# 	@app_response[:data] = {
		# 			code: 'NOT_FOUND',
		# 			support_phone_number: TWILIO_PHONE_NUMBER,
		# 			message: "Cannot Complete Initialization - Clover ID #{mid} not found",
		# 			client_id: SERVICE_NAME
		# 		}
		# else
		# 	success({
		# 			code: 'INITIALIZED',
		# 			support_phone_number: TWILIO_PHONE_NUMBER,
		# 			application_key: 'MOCK__TESTAPPLICATIONKEYUYh2u3fh23iohfu293',
		# 			message: 'ItsOnMe App Initialized - ready to redeem gift cards!',
		# 			client_id: SERVICE_NAME
		# 		})
		# end
		# respond

	# {"amount"=>"456", "service_charge"=>"null", "tax_amount"=>"0", "code"=>"4567", "merchant_id"=>"J4Q1V4P5X0KS0", "order_id"=>"4ASNH66VTXVRJ", "employee_id"=>"05NZK28JC398W", "note"=>nil, "tip_amount"=>"0", "currency"=>"USD"}

	def redeem
		puts "Web::V3::CloverController (106)" + redeem_params.inspect

		h = {}
		h[:pos_merchant_id] = redeem_params[:merchant_id]
		h[:app_key] = request.headers['HTTP_X_APPLICATION_KEY']
		h[:serial_number] = redeem_params[:serial_number]
		h[:code] = redeem_params[:code]
		h[:amount] = redeem_params[:amount].to_i
		h[:ccy] = redeem_params[:currency]
		h[:auth_token] = redeem_params[:auth_token]
		h[:base_url] = redeem_params[:base_url]

		o = OpsClover.new(h)
		puts o.inspect

		@current_client = o.client
		o.update_status

		case o.stoplight
		when :stop
			fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  You may contact support@itson.me"})
			@app_response[:data] = {
					code: 'NOT_REDEEMABLE',
					message: "Merchant is not active currently.  You may contact support@itson.me",
					client_id: SERVICE_NAME
				}
		when :support
			if o.status == :requested
				screen_msg = "#{SERVICE_NAME} team is setting up your merchant account."
			else
				screen_msg = "#{SERVICE_NAME} Merchant account requires support."
			end
			fail_web({ err: "SUPPORT", msg: screen_msg})
			@app_response[:data] = {
					code: 'SUPPORT',
					message: screen_msg,
					client_id: SERVICE_NAME
				}
		else

			# find redemption by hex_id or token
			rs = o.get_redemptions_for_hex_id_or_token(h[:code])

			@pending_redemption = []
			@done_redemption = []
			@failed_redemption = []

			rs.each do |r|
				if r.status == 'pending'
					@pending_redemption << r
				elsif r.status == 'done'
					@done_redemption << r
				else
					@failed_redemption << r
				end
			end

			if @current_redemption = @pending_redemption.last
				Redeem.change_amount(@current_redemption, h[:amount])
				resp = Redeem.apply_and_complete(redemption: @current_redemption, ticket_num: redeem_params[:order_id], server: redeem_params[:employee_id], client_id: @current_client.id)
	            if !resp.kind_of?(Hash)
	                status = :bad_request
	                fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  You may contact support@itson.me"})
					@app_response[:data] = {
										code: 'NOT_REDEEMABLE',
										message: "Merchant is not active currently.  You may contact support@itson.me",
										client_id: SERVICE_NAME
									}
	            elsif resp["success"] == true
	                gift = resp['gift'] || @current_redemption.gift
	                gift.fire_after_save_queue(@current_client)
	                status = :ok
	                h = resp['response_text']
	                h['code'] = 'SUCCESS'
	                h['message'] = resp['response_text']['msg']
	                h['client_id'] = SERVICE_NAME
	                h['transaction_id'] = @current_redemption.hex_id
	                success(h)
	            else
	                status = :ok
	                fail_web({ err: resp["response_code"], msg: resp["response_text"]})
					@app_response[:data] = {
										code: resp["response_code"],
										message: resp["response_text"],
										client_id: SERVICE_NAME
									}
	            end
			else

				if @current_redemption =  @done_redemption.last

					if @current_redemption.gift_next_value > 0
						fail_web({ err: "NOT_REDEEMABLE", msg:  "Redemption for Voucher Code #{h[:code]} is single use.  To use rest of gift value, print a new voucher or use the ItsOnMe app."})
						@app_response[:data] = {
									amount_applied: 0,
									code: "NOT_REDEEMABLE",
									transaction_reference: h[:code],
									message: "Redemption already complete for Voucher Code #{h[:code]}",
									client_id: SERVICE_NAME
								}
					else
						fail_web({ err: "NOT_REDEEMABLE", msg:  "Redemption already complete for Voucher Code #{h[:code]}"})
						@app_response[:data] = {
									amount_applied: 0,
									code: "NOT_REDEEMABLE",
									transaction_reference: h[:code],
									message: "Redemption already complete for Voucher Code #{h[:code]}",
									client_id: SERVICE_NAME
								}
					end
				else
					fail_web({ err: "NOT_FOUND", msg:  "Gift not found for Voucher Code #{h[:code]}"})
					@app_response[:data] = {
								amount_applied: 0,
								code: "NOT_FOUND",
								transaction_reference: h[:code],
								message: "Gift not found for Voucher Code #{h[:code]}",
								client_id: SERVICE_NAME
							}
				end
			end

		end

		@app_response[:meta] = o.meta
		respond

	end



	# redemptions: []
	# [{
	# 	index_id, item_id, price, quantity, item_name
	# }]


	# [{
	# 	index_id, item_id, amount_applied (reflects quantity)
	# }]

		# x = rand(5)
		# case x
		# when 0
		# 	fail_web({ err: "NOT_FOUND", msg:  "Gift not found for ID #{rcode}"})
		# 	@app_response[:data] = {
		# 				applied_amount: 0,
		# 				code: "NOT_FOUND",
		# 				transaction_reference: rcode,
		# 				message: "Gift not found for ID #{rcode}",
		# 				client_id: SERVICE_NAME
		# 			}
		# when 1
		# 	success({
		# 			applied_amount: amt,
		# 			code: 'PAID' ,
		# 			transaction_reference: 'rd_6412acd3',
		# 			client_id: SERVICE_NAME,
		# 			message: "Transaction Success - #{display_money(ccy: ccy, cents: amt)} has been applied."
		# 		})
		# when 2
		# 	namt = amt / 2
		# 	success({
		# 			applied_amount: namt,
		# 			code: 'PARTIAL_PAID' ,
		# 			transaction_reference: 'rd_6412acd3',
		# 			client_id: SERVICE_NAME,
		# 			message: "Transaction Success - The requested amounts exceeds the gift card value.  #{display_money(ccy: ccy, cents: namt)} has been applied."
		# 		})

		# when 3
		# 	gamt = amt * 4
		# 	success({
		# 			applied_amount: amt,
		# 			code: 'PAID' ,
		# 			transaction_reference: 'rd_6412acd3',
		# 			client_id: SERVICE_NAME,
		# 			message: "Transaction Success - #{display_money(ccy: ccy, cents: amt)} has been applied.  The gift has #{display_money(ccy: ccy, cents: (gamt - amt))} remaining value."
		# 		})

		# else
		# 	fail_web({ err: 'ALREADY_REDEEMED', msg: "Gift has already been redeemed for ID #{rcode}"} )
		# 	@app_response[:data] = {
		# 				applied_amount: 0,
		# 				code: 'ALREADY_REDEEMED',
		# 				transaction_reference: rcode,
		# 				message: "Gift has already been redeemed for ID #{rcode}",
		# 				client_id: SERVICE_NAME
		# 			}
		# end


private


    def init_params
        params.require(:data).permit!
    end

    def redeem_params
        params.require(:data).permit(:base_url, :auth_token, :code, :amount, :service_charge, :tax_amount, :merchant, :merchant_id, :order_id, :employee_id,
        	:note, :tip_amount, :currency, :serial_number)
    end


end


__END__

 {"data"=>{
	 "merchant"=>
		 {"zip"=>"89101", "phone"=>"702-555-1212", "website"=>"https://www.itson.me", "locale"=>"en_US", "state"=>"NV", "vat"=>false,
		 	"address1"=>"123 Mockingbird Lane", "address2"=>"Apt 2b", "device_id"=>"abacc7fc-1f67-4cd5-9f9c-d0073b048fbf", "address3"=>"",
		 	"support_email"=>"dev@clover.com", "city"=>"Las Vegas", "currency"=>"USD", "id"=>"J4Q1V4P5X0KS0", "time_zone"=>"Pacific Standard Time",
		 	"support_phone"=>"(000) 000-0000", "name"=>"ItsOnMe Test Merchant",
		   "account"=>"Account {name=ItsOnMe Test Merchant | richard1@rangerllt.com (DEV), type=com.clover.account}",
		 	"mid"=>"RCTST0000008099"
		  },
	  "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)",
	  "serial_number"=>"[FILTERED]"}
	 }

 if ' ' == x.last
 	x = x[0 ... -1]
 end

 h = init_params[:merchant]
 h[:app_key] = request.headers['HTTP_X_APPLICATION_KEY']
 h[:serial_number] = init_params[:serial_number]
 h[:merchant_id] = h[:id]

 {"merchant"=>
 	{"zip"=>"89101",
 		"phone"=>"702-555-1212",
 		"website"=>"https://www.itson.me",
 		 "locale"=>"en_US",
 		 "state"=>"NV",
 		 "vat"=>false,
 		 "address1"=>"123 Mockingbird Lane",
 		 "address2"=>"Apt 2b",
 		 "device_id"=>"abacc7fc-1f67-4cd5-9f9c-d0073b048fbf",
 		 "address3"=>"",
 		 "support_email"=>"dev@clover.com",
 		  "city"=>"Las Vegas",
 		  "currency"=>"USD",
 		  "id"=>"J4Q1V4P5X0KS0",
 		  "time_zone"=>"Pacific Standard Time",
 		  "email"=>"richard1@rangerllt.com ",
 		  "support_phone"=>"(000) 000-0000",
 		  "name"=>"ItsOnMe Test Merchant",
 		  "account"=>"Account {name=ItsOnMe Test Merchant | richard1@rangerllt.com (DEV), type=com.clover.account}",
 		  "mid"=>"RCTST0000008099"},
 	 "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)",
 	 "serial_number"=>"b73f3293e5b33823"}




