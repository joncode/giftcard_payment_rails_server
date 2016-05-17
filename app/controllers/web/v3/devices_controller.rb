class Web::V3::DevicesController < MetalCorsController

    before_action :authentication_no_token, only: [:config]
    before_action :authentication_token_required , only: [:create]


	def create
		begin
			if @current_user.pn_token = [token_params[:token], token_params[:platform]]
				success "Token Saved"
			else
				fail_web({
	                err: "TOKEN_NOT_SAVED",
	                msg: "Data Not Token"
	            })
			end
		rescue
			fail_web({
                err: "TOKEN_NOT_SAVED",
                msg: "Data Corrupted"
            })
		end
		respond
	end

    def config
        config_hsh = {
            version: VERSION_NUMBER,
            service_name: SERVICE_NAME,
            public_url: PUBLIC_URL,
            support: {
                email: SUPPORT_EMAIL,
                phone: TWILIO_PHONE_NUMBER
            },
            photos: {
                blank_avatar_url: BLANK_AVATAR_URL,
                receipt_image_url: DEFAULT_RECEIPT_IMG_URL,
            },
            ccy: CCY
        }
        success config_hsh
        respond
    end


private

	def token_params
		require(:data).permit(:token, :platform)
	end



end