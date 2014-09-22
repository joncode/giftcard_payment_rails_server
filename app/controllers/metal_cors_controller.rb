class MetalCorsController < MetalController

    after_filter         :cross_origin_allow_header

private

    def cross_origin_allow_header
        headers['Access-Control-Allow-Origin']   = "*"
        headers['Access-Control-Allow-Methods']  = 'POST, PUT, DELETE, GET, OPTIONS'
        headers['Access-Control-Request-Method'] = '*'
        headers['Access-Control-Allow-Headers']  = 'Origin, X-Requested-With, Content-Type, Accept, TKN, Mdot-Version, Android-Version'
    end

end





















