class Mdot::V2::ContactsController < JsonController
    before_action :authenticate_customer
    rescue_from JSON::ParserError, :with => :bad_request

    def upload
        contacts = BulkContact.upload(data: params["data"], user_id: @current_user.id)
        if contacts.class == BulkContact
            success "ok"
        else
            status = 501
            fail   "Bulk Upload failed"
        end
        respond(status)
    end

end