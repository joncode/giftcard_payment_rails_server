class Web::V3::PromosController < MetalCorsController

    before_action :authentication_no_token
    rescue_from ActiveRecord::RecordNotFound, :with => :not_found

	def show
        lp = LandingPage.find_by!(link: params[:id])
        success lp.page_json
        respond
	end

	def click
		lp = LandingPage.click(link: click_params[:link])
		if lp.errors.messages == {}
			success({link: lp.link})
		else
			fail_web({ err: "INVALID_INPUT", msg: "Click could not be registered"})
		end
		respond
	end

	def create
		input = create_params
		input['client_id'] = @current_client.id
		input['partner_id'] = @current_partner.id
		input['partner_type'] = @current_partner.class.to_s
		gift  = GiftAffiliate.create(input)
		if gift.kind_of?(Gift) && gift.persisted?
			success gift.web_serialize
		else
			fail_web({ err: "INVALID_INPUT", msg: "Gift could not be created", data: gift})
		end
		respond
	end

	# def redbull
	# 	input = {}
	# 	request_params = redbull_params
	# 	merchant = Merchant.find(request_params[:loc_id])
	# 	menu_item = MenuItem.get_voucher_for_amount(merchant.menu_id, '40')
	# 	input['shoppingCart'] = [menu_item.serialize_with_quantity(1)].to_json
	# 	input['client_id'] = @current_client.id
	# 	input['partner_id'] = @current_partner.id
	# 	input['partner_type'] = @current_partner.class.to_s
	# 	input['merchant_id'] = merchant.id
	# 	input['receiver_email'] = request_params[:email]
	# 	input['receiver_name'] = request_params[:email]
	# 	input['message'] = "A Perfect Pour deserves a Perfect Gift, Thanks for being awesome."
	# 	input['detail'] = "Redbull Perfect Pour Thank You gift."
	# 	gift  = GiftPromo.create(input)
	# 	if gift.kind_of?(Gift) && gift.persisted?
	# 		success ({ gift_id: gift.id, email: gift.receiver_email, loc_id: gift.merchant_id })
	# 	else
	# 		status = :bad_request
	# 		fail_web({ err: "INVALID_INPUT", msg: "Gift could not be created", data: gift})
	# 	end
	# 	respond(status)

	# end


private

	# def redbull_params
	# 	params.require(:data).permit(:loc_id, :email)
	# end

	def click_params
		params.require(:data).permit(:link)
	end

    def create_params
        params.require(:data).permit(:rec_net, :rec_net_id, :c_item_id, :link)
    end
end