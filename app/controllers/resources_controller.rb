class ResourcesController < ApplicationController

    # GET /resources/qr?content=
    def qr
        # Default options
        options = {
            fill:  'white',
            color: 'black',
            size:  120,
            border_modules: 2,
            # module_px_size: 6,
            # resize_gte_to: false,
            # resize_exactly_to: false,
        }

        # Expose some to the consumer
        options[:size]           = params[:size].to_i     if params[:size].present?
        options[:fill]           = params[:fill].strip    if params[:fill].present?
        options[:color]          = params[:color].strip   if params[:color].present?
        options[:border_modules] = params[:padding].to_i  if params[:padding].present?

        # Query params that begin with a `#` do not go through
        # so let's convert 3/6-length hex into hex colors, e.g. "0000ff" -> "#0000ff"
        options[:fill]  = "##{options[:fill]}"   if options[:fill].match(/([0-9a-f]{3}|[0-9a-f]{6})/).present?
        options[:color] = "##{options[:color]}"  if options[:color].match(/([0-9a-f]{3}|[0-9a-f]{6})/).present?


        # Guards
        return head 400  if params[:content].nil? || params[:content].strip.empty?
        return head 400  if options[:border_modules] < 0
        return head 400  if options[:size] < 20


        send_data(
            RQRCode::QRCode.new(params[:content]).as_png(options),
            type: 'image/png',
            disposition: 'inline'
        )

    rescue => e
        head 400
        puts "500 Internal Error within /resources/qr"
        puts " | message: #{e.message}"
        puts " | params:  #{params.inspect}"
    end

end
