class AdminController < ApplicationController
  	before_filter :signed_in_user
  	before_filter :admin_user?

	def show
	    @offset = params[:offset].to_i || 0
	    @page = @offset
	    paginate = 7
	    @providers = Provider.limit(paginate).offset(@offset)
	    if @providers.count == paginate
	      @offset += paginate 
	    else
	      @offset = 0
	    end
	end

end
