class Web::V3::CloverController < MetalCorsController

	before_action :authentication_no_token, only: [ :redeem ]
	before_action :authenticate_general, only: [ :init ]


	def init
		puts params.inspect
		# use information from the clover machine
		# generate a client key for this clover
		# how do we connect the clover machine to the merchant record ?
		success({
				status: 1,
				code: 'INITIALIZED',
				support_phone_number: TWILIO_PHONE_NUMBER,
				application_key: '9ih2ihf2i03h0i2jd23ijd20idje2fw1ihf1i',
				message: 'ItsOnMe App Initialized - ready to redeem gift cards!'
			})
		respond
	end

	def redeem
		puts redeem_params.inspect
		success({
					applied_amount: 0,
					code: "NOT_FOUND",
					transaction_reference: 'rd_ccd31145',
					message: 'Gift not found for ID RD-8482-AD45'
				})
		respond
	end


private


    def init_params
        params.require(:data).permit!
    end

    def redeem_params
        params.require(:data).permit(:code)
    end


end