class UserFirstNameValidator < ActiveModel::Validator

    def validate(record)
        if record.first_name_changed?
            validator_method(record, "first_name")
        end
    end

private

    def validator_method(record, attribute)
        # if record.active
        #     UserSocial.where(active: true).each do |us|
        #         if us.type_of == attribute && us.identifier == record.send(attribute)
        #             return record.errors[attribute.to_sym] << "is already in use. Please email support@itson.me for assistance if this is in error"
        #         end
        #     end
        # end
        if record.first_name == "(null)"
            return record.errors[attribute.to_sym] << "Account creation was not successful. Please go back one screen, re-enter your first name and re-submit. Thanks."
        end
    end
end