class Web::V3::PromosController < MetalCorsController

    before_action :authenticate_user
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

	def show
        lp = LandingPage.find_by!(link: params[:id])
        success lp.page_json
        respond
	end

	def create
		input = create_params
		gift = GiftAffiliate.create(create_params)
		if gift.kind_of?(Gift)
			success gift.web_serialize
		else
			fail_web({ err: "INVALID_INPUT", msg: "Gift could not be created", data: gift})
		end
		respond
	end

private

    def create_params
        params.require(:data).permit(:rec_net, :rec_net_id, :c_item_id, :link)
    end
end