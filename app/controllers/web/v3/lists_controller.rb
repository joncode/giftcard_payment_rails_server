class Web::V3::MerchantsController < MetalCorsController

    before_action :authentication_no_token

    def index
    	list = List.find_by_owner @current_client
    	if list.kind_of?(List)
			success list
		else
			fail_web({ err: "INVALID_INPUT", msg: "List could not be found for application"})
		end
		respond
    end

    def show
    	id_or_url_slug = params[:id]
    	l_id = id_or_url_slug.to_i
    	if l_id == 0
    		list = List.find_by token: id_or_url_slug
    	else
	    	list = List.find id_or_url_slug
	    end
    	if list.kind_of?(List)
			success list
		else
			fail_web({ err: "INVALID_INPUT", msg: "List could not be found"})
		end

		respond
    end

end