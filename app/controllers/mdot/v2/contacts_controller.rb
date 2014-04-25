class Mdot::V2::ContactsController < JsonController
    before_action :authenticate_customer

    def upload
        if Rails.env.production?
            success "ok"
        else
            contacts = BulkContact.upload(data: params["data"], user_id: @current_user.id)
            if contacts.class == BulkContact
                success "ok"
            else
                status = 501
                fail   "Bulk Upload failed"
            end
        end
        respond(status)
    end

end