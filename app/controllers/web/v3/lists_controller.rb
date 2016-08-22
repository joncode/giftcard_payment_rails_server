class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index
    	list = List.find_by_owner @current_client
    	if list.kind_of?(List)
			success client
		else
			fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
		end
		respond
    end

    def show
    	list = List.find params[:id]
    	if list.kind_of?(List)
			success list
		else
			fail_web({ err: "INVALID_INPUT", msg: "Client could not be found"})
		end

		respond
    end

end