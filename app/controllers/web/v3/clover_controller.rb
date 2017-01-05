class Web::V3::CloverController < MetalCorsController
	include MoneyHelper

	before_action :authentication_no_token, only: [ :redeem ]
	before_action :authenticate_general, only: [ :init ]


	def init
		puts params.inspect
		# use information from the clover machine
		# generate a client key for this clover
		# how do we connect the clover machine to the merchant record ?
		success({
				code: 'INITIALIZED',
				support_phone_number: TWILIO_PHONE_NUMBER.gsub('+', ''),
				application_key: Client.where(active: true).last.application_key,
				message: 'ItsOnMe App Initialized - ready to redeem gift cards!',
				client_id: SERVICE_NAME
			})
		respond
	end

	# {"amount"=>"456", "service_charge"=>"null", "tax_amount"=>"0", "code"=>"4567", "merchant_id"=>"J4Q1V4P5X0KS0", "order_id"=>"4ASNH66VTXVRJ", "employee_id"=>"05NZK28JC398W", "note"=>nil, "tip_amount"=>"0", "currency"=>"USD"}

	def redeem
		puts redeem_params.inspect
		rcode = redeem_params[:code]
		amt = redeem_params[:amount].to_i
		ccy = redeem_params[:currency]

		x = rand(5)

		# find redemption by hex_id or token
		@current_redemption = Redemption.find_with_merchant_hex_id_or_token(rcode)

		if @current_redemption.nil?
			# return not found
		else
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
		end

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
        params.require(:data).permit!
    end

    def redeem_params
        params.require(:data).permit(:code, :amount, :service_charge, :tax_amount, :merchant_id, :order_id, :employee_id, :note, :tip_amount, :currency)
    end


end