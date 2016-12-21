class Web::V3::CloverController < MetalCorsController

	before_action :authentication_no_token, only: [ :redeem ]
	before_action :authenticate_general, only: [ :init ]


	def init
		puts init_params.inspect
		success({
				status: 1,
				code: 'INITIALIZED',
				support_phone_number: '1-310-235-3835',
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
        params.require(:data).permit(:system)
    end

    def redeem_params
        params.require(:data).permit(:system)
    end


end