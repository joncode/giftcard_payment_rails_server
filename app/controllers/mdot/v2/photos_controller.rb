class Mdot::V2::PhotosController < JsonController
    before_filter :authenticate_customer

    def create
        return nil if params_bad_request
        return nil if data_blank?
        return nil if data_not_string?
        if @current_user.update_attributes(iphone_photo: photo_params)
            success "Photo Updated - Thank you!"
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