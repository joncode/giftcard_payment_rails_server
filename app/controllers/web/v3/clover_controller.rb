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
				message: 'ItsOnMe App Initialized - ready to redeem gift cards!'
			})
		respond
	end

	# {"amount"=>"456", "service_charge"=>"null", "tax_amount"=>"0", "code"=>"4567", "merchant_id"=>"J4Q1V4P5X0KS0", "order_id"=>"4ASNH66VTXVRJ", "employee_id"=>"05NZK28JC398W", "note"=>nil, "tip_amount"=>"0", "currency"=>"USD"}

	def redeem
		puts redeem_params.inspect
		rcode = redeem_params[:code]
		amt = redeem_params[:amount].to_i
		ccy = redeem_params[:currency]
		# success({
		# 			applied_amount: 0,
		# 			code: "NOT_FOUND",
		# 			transaction_reference: rcode,
		# 			message: "Gift not found for ID #{rcode}"
		# 		})


		fail_web({
					applied_amount: display_money(ccy: ccy, cents: amt),
					code: 'ALREADY_REDEEMED',
					transaction_reference: rcode,
					message: "Gift has already been redeemed for ID #{rcode}"
				})
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