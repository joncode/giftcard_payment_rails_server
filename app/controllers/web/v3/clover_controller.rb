class Web::V3::CloverController < MetalCorsController
	include MoneyHelper

	before_action :authentication_no_token, only: [ :redeem ]
	before_action :authenticate_general, only: [ :init ]



	# {"merchant_id"=>"J4Q1V4P5X0KS0", "application_key"=>"DXVQlmSoxvSo-lnKazbk2wTJkZtAIA-_Ot-gtFc--79Q", "name"=>"ItsOnMe Test Merchant | richard1@rangerllt.com (DEV)"}

	def init
		puts params.inspect
		mid = init_params[:merchant_id]
		app_key = init_params[:application_key]
		name = init_params[:name].split('|')[0]
		email = init_params[:name].split('|')[1].gsub(' ','').gsub("(DEV)",'')
		venue_url = init_params[:serial_number]
		# if app_key
		# 	client = Client.include(:partner).find_by(application_key: app_key)
		# 	if client && client.active
		# 		partner = client.partner
		# 		if partner.pos_merchant_id == mid
		# 			# good to go
		# 		else
		# 			# machine has incorrect application key / merchant ID sync
		# 		end
		# 	else
		# 		# client not found with application key
		# 	end
		# else
		# 	m = Merchant.find_by(pos_merchant_id: mid)
		# 	if m
		# 		client = Client.new_clover_client(m)
		# 		if client.save
		# 			# ready to go
		# 		else
		# 			# failed attempt to make a client
		# 		end
		# 	else
		# 		# merchant not found via clover merchant_id
		# 	end
		# end
		# use information from the clover machine
		# generate a client key for this clover
		# how do we connect the clover machine to the merchant record ?

		x = rand(2)

		if x == 1
			fail_web({ err: "NOT_FOUND", msg:  "Cannot Complete Initialization - Clover ID #{mid} not found"})
			@app_response[:data] = {
					code: 'NOT_FOUND',
					support_phone_number: TWILIO_PHONE_NUMBER,
					message: "Cannot Complete Initialization - Clover ID #{mid} not found",
					client_id: SERVICE_NAME
				}
		else
			success({
					code: 'INITIALIZED',
					support_phone_number: TWILIO_PHONE_NUMBER,
					application_key: 'MOCK__TESTAPPLICATIONKEYUYh2u3fh23iohfu293',
					message: 'ItsOnMe App Initialized - ready to redeem gift cards!',
					client_id: SERVICE_NAME
				})
		end
		respond
	end

	# {"amount"=>"456", "service_charge"=>"null", "tax_amount"=>"0", "code"=>"4567", "merchant_id"=>"J4Q1V4P5X0KS0", "order_id"=>"4ASNH66VTXVRJ", "employee_id"=>"05NZK28JC398W", "note"=>nil, "tip_amount"=>"0", "currency"=>"USD"}

	def redeem
		puts redeem_params.inspect
		rcode = redeem_params[:code]
		amt = redeem_params[:amount].to_i
		ccy = redeem_params[:currency]


		# find redemption by hex_id or token
		# rs = @current_client.partner.get_redemptions_for_hex_id_or_token(rcode)

		# rs.each do |r|
		# 	if r.status == 'pending'
		# 		@current_redemption = r
		# 		break
		# 	end
		# end

		# if rs.blank?
		# 	# return not found
		# elsif @current_redemption.nil?
			# return not redeemable or already redeemed
			# done_redemption = nil
			# failed_redemption = nil
			# rs.each do |r|
			# 	if r.status == 'done'
			# 		done_redemption = r
			# 	else
			# 		failed_redemption = r
			# 	end
			# end
			# if done_redemption.present?
			# 	# return already redeemed msg
			# else
			# 	# return redemption cancelled msg
			# end
		# else
		# 	resp = Redeem.apply_and_complete(redemption: @current_redemption, ticket_num: redeem_params[:order_id], server: redeem_params[:employee_id], client_id: @current_client.id)
  #           if !resp.kind_of?(Hash)
  #               status = :bad_request
  #               fail_web({ err: "NOT_REDEEMABLE", msg: "Merchant is not active currently.  Please contact support@itson.me"})
  #           elsif resp["success"] == true
  #               gift.fire_after_save_queue(@current_client)
  #               status = :ok
  #               success({msg: resp["response_text"]})
  #           else
  #               status = :ok
  #               fail_web({ err: resp["response_code"], msg: resp["response_text"]})
  #           end
		# end

		x = rand(5)
		case x
		when 0
			fail_web({ err: "NOT_FOUND", msg:  "Gift not found for ID #{rcode}"})
			@app_response[:data] = {
						applied_amount: 0,
						code: "NOT_FOUND",
						transaction_reference: rcode,
						message: "Gift not found for ID #{rcode}",
						client_id: SERVICE_NAME
					}
		when 1
			success({
					applied_amount: amt,
					code: 'PAID' ,
					transaction_reference: 'rd_6412acd3',
					client_id: SERVICE_NAME,
					message: "Transaction Success - #{display_money(ccy: ccy, cents: amt)} has been applied."
				})
		when 2
			namt = amt / 2
			success({
					applied_amount: namt,
					code: 'PARTIAL_PAID' ,
					transaction_reference: 'rd_6412acd3',
					client_id: SERVICE_NAME,
					message: "Transaction Success - The requested amounts exceeds the gift card value.  #{display_money(ccy: ccy, cents: namt)} has been applied."
				})

		when 3
			gamt = amt * 4
			success({
					applied_amount: amt,
					code: 'PAID' ,
					transaction_reference: 'rd_6412acd3',
					client_id: SERVICE_NAME,
					message: "Transaction Success - #{display_money(ccy: ccy, cents: amt)} has been applied.  The gift has #{display_money(ccy: ccy, cents: (gamt - amt))} remaining value."
				})

		else
			fail_web({ err: 'ALREADY_REDEEMED', msg: "Gift has already been redeemed for ID #{rcode}"} )
			@app_response[:data] = {
						applied_amount: 0,
						code: 'ALREADY_REDEEMED',
						transaction_reference: rcode,
						message: "Gift has already been redeemed for ID #{rcode}",
						client_id: SERVICE_NAME
					}
		end
		respond
	end


private


    def init_params
        params.require(:data).permit(:application_key, :name, :merchant_id, :serial_number)
    end

    def redeem_params
        params.require(:data).permit(:code, :amount, :service_charge, :tax_amount, :merchant_id, :order_id, :employee_id, :note, :tip_amount, :currency, :serial_number)
    end


end