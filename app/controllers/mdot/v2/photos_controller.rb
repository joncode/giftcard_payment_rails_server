class Mdot::V2::PhotosController < JsonController
    before_filter :authenticate_customer

    def create
        return nil if data_blank?
        return nil if data_not_string?
        if @current_user.update_attributes(iphone_photo: params["data"], use_photo: "ios")
            success { "user_id" => @current_user.id, "user" => @current_user.serialize }
        else
            fail    @current_user
        end
        respond
    end

end