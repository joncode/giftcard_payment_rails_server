class Mdot::V2::ContactsController < JsonController
    before_action :authenticate_customer

    def upload
        contacts = AppContact.upload(contacts: params["data"], user: @current_user)
        if contacts.first.class == AppContact
            success contacts.count
        else
            status = 501
            fail   "Bulk Upload failed"
        end
        respond(status)
    end

end