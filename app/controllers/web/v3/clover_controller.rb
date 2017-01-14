class Web::V3::CloverController < MetalCorsController
	include MoneyHelper

	before_action :authentication_clover, only: [ :redeem, :init ]



	# {"merchant_id"=>"J4Q1V4P5X0KS0", "application_key"=>"DXVQlmSoxvSo-lnKazbk2wTJkZtAIA-_Ot-gtFc--79Q", "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)"}

	def init
		puts params.inspect
		h = {}
		h[:mid] = init_params[:merchant_id]
		h[:app_key] = request.headers['HTTP_X_APPLICATION_KEY']
		h[:name] = init_params[:name].split(' | ')[0]
		h[:email] = init_params[:name].split(' | ')[1].gsub("(DEV)",'').gsub(' ','').chomp
		h[:device_id] = init_params[:serial_number]

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
					message: 'ItsOnMe Tender Initialized - ready to redeem gift cards!',
					client_id: SERVICE_NAME,
					application_key: o.key
				})
		else #:support
			fail_web({ err: "SUPPORT", msg:  "Clover connection is #{o.status}"})
			@app_response[:data] = {
					code: 'SUPPORT',
					message: "Clover connection is #{o.status}",
					client_id: SERVICE_NAME
				}
		end
		@app_response[:meta] = o.meta
		respond

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
	end

	# {"amount"=>"456", "service_charge"=>"null", "tax_amount"=>"0", "code"=>"4567", "merchant_id"=>"J4Q1V4P5X0KS0", "order_id"=>"4ASNH66VTXVRJ", "employee_id"=>"05NZK28JC398W", "note"=>nil, "tip_amount"=>"0", "currency"=>"USD"}

	def redeem
		puts redeem_params.inspect

		h = {}
		h[:mid] = redeem_params[:merchant_id]
		h[:app_key] = request.headers['HTTP_X_APPLICATION_KEY']
		@current_client = Client.find_by(applications_key: h[:app_key]) if h[:app_key].present?
		h[:device_id] = redeem_params[:serial_number]
		h[:code] = redeem_params[:code]
		h[:amount] = redeem_params[:amount].to_i
		h[:ccy] = redeem_params[:currency]

		o = OpsClover.new(h)
		puts o.inspect

		o.update_status

		case o.stoplight
		when :stop
			fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
			@app_response[:data] = {
					code: 'NOT_REDEEMABLE',
					message: "Merchant is not active currently.  Please contact support@itson.me",
					client_id: SERVICE_NAME
				}
		when :support
			fail_web({ err: "SUPPORT", msg:  "Clover connection is #{o.status}"})
			@app_response[:data] = {
					code: 'SUPPORT',
					message: "Clover connection is #{o.status}",
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
				resp = Redeem.apply_and_complete(redemption: @current_redemption, ticket_num: redeem_params[:order_id], server: redeem_params[:employee_id], client_id: @current_client.id)
	            if !resp.kind_of?(Hash)
	                status = :bad_request
	                fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
	            elsif resp["success"] == true
	                gift.fire_after_save_queue(@current_client)
	                status = :ok
	                success({msg: resp["response_text"]})
	            else
	                status = :ok
	                fail_web({ err: resp["response_code"], msg: resp["response_text"]})
	            end
			else

				fail_web({ err: "NOT_FOUND", msg:  "Gift not found for Voucher Code #{h[:code]}"})
				@app_response[:data] = {
							applied_amount: 0,
							code: "NOT_FOUND",
							transaction_reference: h[:code],
							message: "Gift not found for Voucher Code #{h[:code]}",
							client_id: SERVICE_NAME
						}

			end

		end

		@app_response[:meta] = o.meta
		respond


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
	end


private


    def init_params
        params.require(:data).permit(:application_key, :name, :merchant_id, :serial_number)
    end

    def redeem_params
        params.require(:data).permit(:code, :amount, :service_charge, :tax_amount, :merchant_id, :order_id, :employee_id, :note, :tip_amount, :currency, :serial_number, :application_key)
    end


end