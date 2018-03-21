class ResourcesController < ApplicationController

    # GET /resources/qr?content=
    def qr
        send_data(
            RQRCode::QRCode.new(params[:content]).as_png,
            type: 'image/png',
            disposition: 'inline'
        )
    end

end
