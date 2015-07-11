class Mdot::V2::PhotosController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def create
        return nil if params_bad_request
        return nil if data_blank?
        return nil if data_not_string?
        if @current_user.update(iphone_photo: photo_params)
            success @current_user.update_serialize
        else
            fail    @current_user
            status = :bad_request
        end
        respond(status)
    end

private

    def photo_params
        params.require(:data)
    end

end