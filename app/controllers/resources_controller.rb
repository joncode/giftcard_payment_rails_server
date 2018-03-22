class ResourcesController < ApplicationController

    # GET /resources/qr?content=
    def qr
        return head 400  if params[:content].nil? || params[:content].strip.empty?

        # Not particularly useful, but let's expose it anyway.
        options = {}
        options[:size] = params[:size].to_i  if params[:size].present?

        send_data(
            RQRCode::QRCode.new(
                params[:content],
                options
            ).as_png,
            type: 'image/png',
            disposition: 'inline'
        )
    end

end
