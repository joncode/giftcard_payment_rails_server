class Web::V3::ListsController < MetalCorsController

    before_action :authentication_no_token

    def index
    	list = @current_client.list
    	if list.kind_of?(List)
			success list
		else
			fail_web({ err: "INVALID_INPUT", msg: "List could not be found for application"})
		end
		respond
    end

    def show
    	id_or_slug = params[:id]
    	if id_or_slug.gsub(/[0-9]/, '').length != 0
    		list = List.find_by token: id_or_slug
    	else
	    	list = List.find id_or_slug
	    end
    	if list.kind_of?(List)
			success list
		else
			fail_web({ err: "INVALID_INPUT", msg: "List could not be found"})
		end

		respond
    end

end