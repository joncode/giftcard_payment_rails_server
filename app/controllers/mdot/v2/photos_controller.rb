class Mdot::V2::PhotosController < JsonController
    before_filter :authenticate_customer

    def create
        return nil if data_blank?
        return nil if data_not_string?
        if @current_user.update_attributes(iphone_photo: params["data"], use_photo: "ios")
            success @current_user.update_serialize
        else
            fail    @current_user
        end
        respond
    end

end