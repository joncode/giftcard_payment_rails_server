class Web::V3::CloverController < MetalCorsController

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

	def redeem
		puts redeem_params.inspect

		if @client.nil?
			head :unauthorized
		else
			success({
						applied_amount: 0,
						code: "NOT_FOUND",
						transaction_reference: 'rd_ccd31145',
						message: 'Gift not found for ID RD-8482-AD45'
					})
			respond
		end
	end


private


    def init_params
        params.require(:data).permit!
    end

    def redeem_params
        params.require(:data).permit(:code)
    end


end