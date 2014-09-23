class MetalCorsController < MetalController

	before_action :print_params
    after_filter         :cross_origin_allow_header
    after_action :print_params
    
private

	def print_params
		puts "-------- mccontroller params #{params.inspect}"
	end

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin']   = "*"
        headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, TKN, Mdot-Version, Android-Version'
        headers['Content-Type']                  = "application/json"
        headers['Accept']                        = "application/json"
    end

end





















