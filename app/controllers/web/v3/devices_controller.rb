class Web::V3::DevicesController < MetalCorsController

    before_action :authentication_no_token, only: [:config]
    before_action :authentication_token_required , only: [:create]


	def create
        puts token_params.inspect
        pnt = PnToken.find_or_create_token(
                @current_user.id,
                token_params[:token],
                token_params[:platform],
                token_params[:device_id]
        )
        if pnt.persisted?
            @current_session.update(push: pnt.pn_token)
			success "Token Saved"
		else
			fail_web({
                err: "TOKEN_NOT_SAVED",
                msg: "Data Not Token"
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
                phone: TWILIO_PHONE_NUMBER,
                help_desk_url: HELP_DESK_URL
            },
            photos: {
                blank_avatar_url: BLANK_AVATAR_URL,
                receipt_image_url: DEFAULT_RECEIPT_IMG_URL
            },
            redemption_policies: [
               {
                   header: "Redemption Policy",
                   items: [
                       "The gift amount may be partially redeemed or used all at once.",
                       "Unused portions of this gift cannot be exchanged for cash."
                   ]
               },
               {
                   header: "How To Redeem",
                   items: [
                       "The gift is a form of payment, it does not need to be presented prior to ordering. Think of it as a credit or gift card.",
                       "This gift does not guarantee you a reservation or the ability to order.",
                       "If you are under age or do not have proper ID, you may be refused service.",
                       "At checkout inform the cashier or server that you have ItsOnMe for all or part of your bill."
                   ]
               },
               {
                   footer: "Don’t Forget to Tip!"
               }
            ],
            ccy: CCY,
            service_percent: 0.05
        }
        success config_hsh
        respond
    end


private


	def token_params
		params.require(:data).permit(:token, :platform, :device_id)
	end

end